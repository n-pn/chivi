require "log"
require "colorize"
require "file_utils"

require "./vp_dict/*"

class CV::VpDict
  DIR = "var/vpdicts"
  ::FileUtils.mkdir_p("#{DIR}/basic")
  ::FileUtils.mkdir_p("#{DIR}/novel")
  ::FileUtils.mkdir_p("#{DIR}/theme")

  class_getter trungviet : self { load("trungviet") }
  class_getter cc_cedict : self { load("cc_cedict") }
  class_getter trich_dan : self { load("trich_dan") }

  class_getter hanviet : self { load("hanviet") }
  class_getter pin_yin : self { load("pin_yin") }
  class_getter tradsim : self { load("tradsim") }

  class_getter essence : self { load("essence") }
  class_getter regular : self { load("regular") }
  class_getter fixture : self { load("fixture") }

  class_getter combine : self { load("combine") }
  class_getter suggest : self { load("suggest") }

  class_getter novels : Array(String) do
    files = Dir.glob("#{DIR}/novel/*.tab")
    files.sort_by! { |f| File.info(f).modification_time.to_unix.- }
    files.map { |f| File.basename(f, ".tab") }
  end

  class_getter themes : Array(String) do
    files = Dir.glob("#{DIR}/theme/*.tab")
    files.sort_by! { |f| File.info(f).modification_time.to_unix.- }
    files.map { |f| File.basename(f, ".tab") }
  end

  BASICS = {} of String => self
  NOVELS = {} of String => self
  THEMES = {} of String => self

  def self.load(dname : String, scope = "novel", reset = false)
    case dname
    when "trungviet", "cc_cedict", "trich_dan"
      BASICS[dname] ||= new(path(dname, "miscs"), dtype: 0)
    when "tradsim", "hanviet", "pin_yin"
      BASICS[dname] ||= new(path(dname, "miscs"), dtype: 1, reset: reset)
    when "essence", "fixture"
      BASICS[dname] ||= new(path(dname, "basic"), dtype: 1, reset: reset)
    when "regular", "suggest"
      BASICS[dname] ||= new(path(dname, "basic"), dtype: 2, reset: reset)
    when "combine"
      BASICS[dname] ||= new(path(dname, "basic"), dtype: 3, reset: reset)
    else
      cached = scope == "novel" ? NOVELS : THEMES
      cached[dname] ||= new(path(dname, scope), dtype: 3, reset: reset)
    end
  end

  def self.path(label : String, scope : String = ".")
    File.join(DIR, scope, label + ".tsv")
  end

  #########################

  getter file : String
  getter ftab : String
  getter size = 0

  getter trie = VpTrie.new
  getter data = [] of VpTerm

  getter dtype : Int32 # dict type

  # forward_missing_to @data
  delegate scan, to: @trie

  def initialize(@file : String, @dtype = 1, reset = false)
    @ftab = @file.sub(".tsv", ".tab")
    return if reset

    load!(@file) if File.exists?(@file)
    load!(@ftab) if File.exists?(@ftab)
  end

  def load!(file : String = @file) : Nil
    lines = File.read_lines(file)
    lines.each do |line|
      set(VpTerm.new(line.split('\t'), dtype: @dtype))
    rescue err
      Log.error { "<vp_dict> [#{file}] error on `#{line}`: #{err}]".colorize.red }
    end

    Log.info { "<vp_dict> [#{file.sub(DIR, "")}] loaded: #{lines.size} lines".colorize.green }
  end

  def find(key : String) : VpTerm?
    @trie.find(key).try(&.base)
  end

  def find(key : String, uname : String) : Tuple(VpTerm?, VpTerm?)
    return {nil, nil} unless node = @trie.find(key)
    {node.base, node.privs[uname]?}
  end

  def set(key : String, vals : Array(String))
    set(VpTerm.new(key, vals, mtime: 0_u32))
  end

  def set(term : VpTerm) : VpTerm?
    @data << term
    return unless @trie.find!(term.key).push!(term)
    @size += 1 if term.state == "Thêm"
    term
  end

  def set!(term : VpTerm) : VpTerm?
    return unless set(term)
    File.open(@ftab, "a") { |io| io << '\n'; term.to_s(io, dtype: @dtype) }
    term
  end

  # set prune level
  # 1: delete overwritten entries
  # 2: delete shadowed entries (update in under 5 minutes)
  # 3: do not delete anything

  def save!(file = @file, prune : Int8 = 2_u8) : Nil
    return if prune < 1

    data = @data.reject { |x| x.key.empty? || x._flag >= prune }
    base_arr, user_arr = data.partition(&.mtime.== 0)

    save_list!(@file, base_arr)
    save_list!(@ftab, user_arr)
  end

  private def save_list!(file : String, list : Array(VpTerm))
    return if list.empty?
    list.sort_by! { |x| {x.mtime, x.key.size, x.key} }

    data = String.build do |io|
      list.each_with_index do |term, i|
        io << "\n" unless i == 0
        term.to_s(io, dtype: @dtype)
      end
    end

    File.write(file, data)
    Log.info { "<vp_dict> [#{file.sub(DIR, "")}] saved, items: #{list.size}".colorize.yellow }
  end

  # check if user has privilege to add new term for this dict
  def allow?(privi : Int32, _priv = false)
    privi += 1 if _priv

    case @dtype
    when 2 then privi > 1
    when 3 then privi > 0
    else        privi > 2
    end
  end
end
