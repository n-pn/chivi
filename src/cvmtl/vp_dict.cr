require "log"
require "colorize"
require "file_utils"

require "./vp_dict/*"

class CV::VpDict
  DIR = "var/vpdicts/v1"
  EXT = ".tsv"

  class_getter trungviet : self { new(path("trungviet", "fixed"), type: -1) }
  class_getter cc_cedict : self { new(path("cc_cedict", "fixed"), type: -1) }
  class_getter trich_dan : self { new(path("trich_dan", "fixed"), type: -1) }

  class_getter hanviet : self { load("hanviet") }
  class_getter pin_yin : self { load("pin_yin") }
  class_getter tradsim : self { load("tradsim") }

  class_getter essence : self { load("essence") }
  class_getter regular : self { load("regular") }
  class_getter fixture : self { load("fixture") }

  class_getter combine : self { load("combine") }
  class_getter suggest : self { load("suggest") }

  class_getter nvdicts : Array(String) do
    files = Dir.glob("#{DIR}/novel/*.tab")
    files.sort_by! { |f| File.info(f).modification_time.to_unix.- }
    files.map { |f| "-" + File.basename(f, ".tab") }
  end

  class_getter qtdicts : Array(String) do
    files = Dir.glob("#{DIR}/cvmtl/*.tsv")
    files.map { |f| "~" + File.basename(f, ".tsv") }
  end

  BASIC = {} of String => self
  NOVEL = {} of String => self
  THEME = {} of String => self

  def self.load(dname : String, mode = 1)
    case dname[0]?
    when '-'
      return NOVEL[dname] ||= new(path(dname[1..], "novel"), type: 3, mode: mode)
    when '!'
      return THEME[dname] ||= new(path(dname[1..], "theme"), type: 2, mode: mode)
    when '~'
      return BASIC[dname] ||= new(path(dname[1..], "cvmtl"), type: 1, mode: mode)
    end

    case dname
    when "tradsim", "hanviet", "pin_yin"
      BASIC[dname] ||= new(path(dname, "basic"), type: 0, mode: mode)
    when "essence", "fixture"
      BASIC[dname] ||= new(path(dname, "basic"), type: 1, mode: mode)
    when "regular", "suggest"
      BASIC[dname] ||= new(path(dname, "basic"), type: 2, mode: mode)
    else
      BASIC[dname] ||= new(path(dname, "basic"), type: 3, mode: mode)
    end
  end

  def self.path(label : String, group : String = ".")
    File.join(DIR, group, label + EXT)
  end

  #########################

  getter file : String
  getter flog : String

  getter trie = VpTrie.new
  getter list = [] of VpTerm

  getter type : Int32 # dict type
  getter size = 0

  # forward_missing_to @list
  delegate scan, to: @trie

  # mode
  # -1: ignore existing dict file
  # 0: load existing dict file if exists
  # 1: load log file
  def initialize(@file : String, @type = 1, mode = 1)
    @flog = @file.sub(EXT, ".tab") # log file path
    return if mode < 0

    load!(@file) if File.exists?(@file)
    load!(@flog) if mode == 1 && File.exists?(@flog)
  end

  def load!(file : String = @file) : Nil
    lines = File.read_lines(file)
    lines.each do |line|
      set(VpTerm.new(line.split('\t'), dtype: @type))
    rescue err
      Log.error { "<vp_dict> [#{file}] error on `#{line}`: #{err}]".colorize.red }
    end

    # Log.info { "<vp_dict> [#{file.sub(DIR, "")}] loaded: #{lines.size} lines".colorize.green }
  end

  def find(key : String) : VpTerm?
    @trie.find(key).try(&.base)
  end

  def find(key : String, uname : String) : Tuple(VpTerm?, VpTerm?)
    return {nil, nil} unless node = @trie.find(key)
    {node.base, node.privs[uname]?}
  end

  def set(key : String, vals : Array(String))
    set(VpTerm.new(key, vals, mtime: 0))
  end

  def set(term : VpTerm) : VpTerm?
    @list << term
    return unless @trie.find!(term.key).push!(term)
    @size += 1 if term.state == "Thêm"
    term
  end

  def set!(term : VpTerm) : VpTerm?
    return unless set(term)
    File.open(@flog, "a") { |io| io << '\n'; term.to_s(io, dtype: @type) }
    term
  end

  # set prune level
  # 1: delete overwritten entries
  # 2: delete shadowed entries (update in under 5 minutes)
  # 3: do not delete anything

  def save!(file = @file, prune : Int8 = 2_u8) : Nil
    return if prune < 1

    data = @list.reject { |x| x.key.empty? || x._flag >= prune }
    save_list!(@file, data) if data.size > 0

    logs = data.select(&.mtime.> 0)
    save_list!(@flog, logs) if logs.size > 0
  end

  private def save_list!(file : String, list : Array(VpTerm))
    return if list.empty?
    list.sort_by! { |x| {x.mtime, x.key.size, x.key} }

    data = String.build do |io|
      list.each_with_index do |term, i|
        io << "\n" unless i == 0
        term.to_s(io, dtype: @type)
      end
    end

    File.write(file, data)
    Log.info { "<vp_dict> [#{file.sub(DIR, "")}] saved, items: #{list.size}".colorize.yellow }
  end
end
