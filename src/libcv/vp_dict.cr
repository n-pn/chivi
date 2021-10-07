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
  class_getter combine : self { load("combine") }
  class_getter fixture : self { load("fixture") }
  class_getter suggest : self { load("suggest") }

  class_getter udicts : Array(String) do
    dirs = Dir.glob("#{DIR}/uniq/*/")
    dirs.sort_by! { |dir| File.info(dir).modification_time.to_unix.- }
    dirs.map { |dir| File.basename(dir) }
  end

  CACHE = {} of String => self

  def self.load(dname : String, stype : String = "_base", reset : Bool = false)
    bonus = stype == "_base" ? 0 : 1

    CACHE[dname + "/" + stype] ||=
      case dname
      when "trungviet", "cc_cedict", "trich_dan", "tradsim"
        new(path(dname), dtype: 0, p_min: 4, reset: reset)
      when "essence", "fixture"
        new(path(dname), dtype: 1, p_min: 4, reset: reset)
      when "suggest", "hanviet", "binh_am"
        new(path("core/#{dname}"), dtype: 1, p_min: 3, reset: reset)
      when "regular"
        new(path("core/regular/#{stype}"), dtype: 2 + bonus, p_min: 2, reset: reset)
      when "combine"
        new(path("core/combine/#{stype}"), dtype: 4 + bonus, p_min: 1, reset: reset)
      else
        new(path("uniq/#{dname}/#{stype}"), dtype: 4 + bonus, p_min: 1, reset: reset)
      end
  end

  def self.path(label : String)
    File.join(DIR, "#{label}.tsv")
  end

  def self.for_lookup(dname : String, stype : String)
    {
      {VpDict.load(dname, stype), "Riêng"},
      {VpDict.load(dname), "Chung"},
      {VpDict.load("regular", stype), "Riêng"},
      {VpDict.regular, "Chung"},
    }
  end

  def self.for_convert(dname : String, stype : String = "chivi")
    [
      essence,                # punctuations, normalize..
      regular,                # public common
      fixture,                # fixed terms
      load(dname),            # public unique
      load("regular", stype), # private common
      load(dname, stype),     # private unique
    ]
  end

  #########################

  getter file : String

  getter trie = VpTrie.new
  getter data = [] of VpTerm

  getter size = 0

  getter dtype : Int32 # dict type
  getter p_min : Int32 # minimal user power required

  def initialize(@file : String, @dtype = 1, @p_min = 1, reset = false)
    load!(@file) if !reset && File.exists?(@file)
  end

  def load!(file : String = @file) : Nil
    start = Time.monotonic
    lines = File.read_lines(file)

    lines.each do |line|
      set(VpTerm.new(line.split('\t'), dtype: @dtype))
    rescue err
      puts "<vp_dict> [#{file}] error on `#{line}`: #{err}]".colorize.red
    end

    tspan = Time.monotonic - start
    puts "- <vp_dict> [#{file}] loaded: #{lines.size} lines, \
          time: #{tspan.total_milliseconds.round.to_i}ms".colorize.green
  end

  def new_term(key : String, val = [""], attr = "", rank = 3_u8, mtime = 0_u32, uname = "~")
    VpTerm.new(key, val, attr, rank, mtime, uname)
  end

  def new_term(term : VpTerm, mtime = term.mtime, uname = term.uname)
    VpTerm.new(term.key, term.val, term.attr, term.rank, mtime, uname)
  end

  def set(key : String, val : Array(String), attr = "")
    set(new_term(key, val, attr))
  end

  def set(term : VpTerm) : VpTerm?
    # find existing node or force creating new one
    node = @trie.find!(term.key)

    if prev = node.term
      # do not record if term is outdated
      return nil if term.mtime < prev.mtime

      if term.amend?(prev) # skipping previous entry if edit under 5 minutes
        prev._flag = 2_u8
        term._prev = prev._prev
      else
        prev._flag = 1_u8
        term._prev = prev
      end
    else
      @size += 1
    end

    @data << term
    node.push(term)
  end

  def set!(new_term : VpTerm) : VpTerm?
    set(new_term).try do
      FileUtils.mkdir_p(File.dirname(@file))
      File.open(@file, "a") { |io| io << '\n'; new_term.to_s(io, dtype: @dtype) }
      new_term
    end
  end

  def find(key : String) : VpTerm?
    @trie.find(key).try(&.term)
  end

  def find!(key : String) : VpTerm
    find(key) || gen_term(key, [""])
  end

  delegate scan, to: @trie

  def each : Nil
    @trie.each do |node|
      node.term.try { |x| yield x }
    end
  end

  def save!(file = @file, prune = 2_u8) : Nil
    start = Time.monotonic

    ::FileUtils.mkdir_p(File.dirname(file))
    @data.sort_by! { |x| {x.mtime, x.key.size, x.key} }

    File.open(@file, "w") do |io|
      @data.each do |term|
        next unless term._flag < prune
        term.to_s(io, dtype: dtype)
        io << '\n'
      end
    end

    tspan = Time.monotonic - start
    puts "- <vp_dict> [#{file}] saved: #{@size} entries, \
          time: #{tspan.total_milliseconds.round.to_i}ms".colorize.yellow
  end
end
