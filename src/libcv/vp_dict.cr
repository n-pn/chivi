require "colorize"
require "file_utils"

require "./vp_dict/*"

class CV::VpDict
  DIR = "db/vpdicts"
  ::FileUtils.mkdir_p("#{DIR}/core")
  ::FileUtils.mkdir_p("#{DIR}/uniq")

  # group: local, chivi, cvdev etc.
  class_property suffix : String = ENV["SUFFIX"]? || "local"

  class_getter trungviet : self { load("trungviet") }
  class_getter cc_cedict : self { load("cc_cedict") }
  class_getter trich_dan : self { load("trich_dan") }

  class_getter tradsim : self { load("tradsim") }
  class_getter binh_am : self { load("binh_am") }
  class_getter hanviet : self { load("hanviet") }

  class_getter essence : self { load("essence") }
  class_getter regular : self { load("regular") }
  class_getter fixture : self { load("fixture") }

  class_getter combine : self { load("combine") }
  class_getter suggest : self { load("suggest") }

  class_getter udicts : Array(String) do
    dirs = Dir.glob("#{DIR}/uniq/*/")
    dirs.sort_by! { |dir| File.info(dir).modification_time.to_unix.- }
    dirs.map { |dir| File.basename(dir) }
  end

  CACHE = {} of String => self

  def self.load(dname : String, reset : Bool = false)
    CACHE[dname] ||=
      case dname
      when "trungviet", "cc_cedict", "trich_dan", "tradsim"
        new(path(dname), dtype: 0, reset: reset)
      when "essence", "fixture"
        new(path(dname), dtype: 1, reset: reset)
      when "suggest", "hanviet", "binh_am"
        new(path("core/#{dname}"), dtype: 1, reset: reset)
      when "regular"
        new(path("core/regular"), dtype: 2, reset: reset)
      when "combine"
        new(path("core/combine"), dtype: 4, reset: reset)
      else
        new(path("uniq/#{dname}"), dtype: 4, reset: reset)
      end
  end

  def self.path(label : String)
    File.join(DIR, "#{label}.tsv")
  end

  #########################

  getter file : String
  getter size = 0

  getter trie = VpTrie.new
  getter data = [] of VpTerm

  getter dtype : Int32 # dict type

  # forward_missing_to @data
  delegate scan, to: @trie

  def initialize(@file : String, @dtype = 1, reset = false)
    if File.exists?(@file)
      load!(@file) unless reset
    else
      FileUtils.mkdir_p(File.dirname(@file))
    end
  end

  def load!(file : String = @file) : Nil
    start = Time.monotonic
    lines = File.read_lines(file)

    lines.each do |line|
      set(VpTerm.new(line.split('\t'), dtype: @dtype))
    rescue err
      puts "<vp_dict> [#{file}] error on `#{line}`: #{err}]".colorize.red
    end

    tspan = (Time.monotonic - start).total_milliseconds.round
    puts "- <vp_dict> [#{file}] loaded: #{lines.size} lines, time: #{tspan}ms".colorize.green
  end

  def set(term : VpTerm) : VpTerm?
    @data << term
    return unless @trie.find!(term.key).push!(term)
    @size += 1 if term.state == "Thêm"
    term
  end

  def set!(term : VpTerm) : VpTerm?
    return unless set(term)
    File.open(@file, "a") { |io| io << '\n'; term.to_s(io, dtype: @dtype) }
    term
  end

  def find(key : String) : VpTerm?
    @trie.find(key).try(&.base)
  end

  def find(key : String, uname : String) : Tuple(VpTerm?, VpTerm?)
    return {nil, nil} unless node = @trie.find(key)
    {node.base, node.privs[uname]?}
  end

  # set prune level
  # 1: delete overwritten entries
  # 2: delete shadowed entries (update in under 5 minutes)
  # 3: do not delete anything

  def save!(file = @file, prune = 2_u8) : Nil
    return if prune < 1

    start = Time.monotonic
    count = 0

    @data.sort_by! { |x| {x.mtime, x.key.size, x.key} } if prune < 3

    File.open(@file, "w") do |io|
      @data.each do |term|
        next if term._flag >= prune

        count += 1
        term.to_s(io, dtype: dtype)
        io << '\n'
      end
    end

    tspan = (Time.monotonic - start).total_milliseconds.round
    puts "- <vp_dict> [#{file}] saved, #{count} entries, time: #{tspan}ms".colorize.yellow
  end

  # check if user has privilege to add new term for this dict
  def allow?(privi : Int32)
    case @dtype
    when 2 then privi > 1
    when 4 then privi > 0
    else        privi > 2
    end
  end
end
