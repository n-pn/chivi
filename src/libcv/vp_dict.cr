require "colorize"
require "file_utils"

require "./vp_dict/*"

class CV::VpDict
  DIR = "_db/vpdict/main"
  ::FileUtils.mkdir_p("#{DIR}/books")

  PLEB = "_db/vpdict/pleb"
  ::FileUtils.mkdir_p("#{PLEB}/books")

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
    files = ::Dir.glob("#{DIR}/books/*.tsv")
    files.sort_by! { |f| File.info(f).modification_time.to_unix.- }
    files.map { |f| File.basename(f, ".tsv") }
  end

  CACHE = {} of String => self

  def self.load(dname : String, reset : Bool = false)
    CACHE[dname] ||=
      case dname
      when "trungviet", "cc_cedict", "trich_dan"
        new("db/vpdicts/#{dname}.tsv", dtype: 0, p_min: 5, reset: reset)
      when "fixture", "essence", "tradsim", "binh_am"
        new("db/vpdicts/#{dname}.tsv", dtype: 1, p_min: 4, reset: reset)
      when "suggest", "hanviet"
        new(path(dname), dtype: 2, p_min: 3, reset: reset)
      when "regular", "combine"
        new(path(dname), dtype: 2, p_min: 2, reset: reset)
      when "pleb_regular"
        new(pleb_path("regular"), dtype: 2, p_min: 2, reset: reset)
      when .starts_with?("pleb_")
        new(pleb_path(dname.sub("pleb_", "books/")), dtype: 3, p_min: 1, reset: reset)
      else
        new(path("books/#{dname}"), dtype: 3, p_min: 1, reset: reset)
      end
  end

  def self.path(label : String)
    File.join(DIR, "#{label}.tsv")
  end

  def self.pleb_path(label : String)
    File.join(PLEB, "#{label}.tsv")
  end

  #########################

  getter file : String
  getter flog : String

  getter trie = VpTrie.new
  getter data = [] of VpTerm

  getter size = 0

  getter dtype : Int32 # dict type
  getter p_min : Int32 # minimal user power required

  def initialize(@file : String, @dtype = 0, @p_min = 1, reset = false)
    @flog = @file.sub("main", "logs").sub(".tsv", ".#{@@suffix}.tsv")
    load!(@file) unless reset || !File.exists?(@file)
  end

  def load!(file : String) : Nil
    count = 0

    tspan = Time.measure do
      File.each_line(file) do |line|
        next if line.strip.blank?

        cols = line.split('\t')
        term = VpTerm.new(cols, dtype: @dtype)
        set(term)

        count += 1
      rescue err
        puts "<vp_dict> [#{file}] error on `#{line}`: #{err}]".colorize.red
      end

      # remove duplicate entries
      @trie.each { |node| node.prune! }
    end

    puts "- <vp_dict> [#{file}] loaded: #{count} lines, \
          time: #{tspan.total_milliseconds.round.to_i}ms".colorize.green
  end

  def new_term(key : String, val = [""], attr = "", rank = 3, mtime = 0, uname = "~")
    VpTerm.new(key, val, attr, rank, mtime, uname, dtype: @dtype)
  end

  def set(key : String, val : Array(String), ext = "")
    term = new_term(key, val, ext)
    set(term)
  end

  # return true if new term prevails
  def set(new_term : VpTerm) : Bool
    @data << new_term

    # find existing node or force creating new one
    node = @trie.find!(new_term.key)

    if old_term = node.term
      newer = new_term.mtime >= old_term.mtime
    else
      newer = true
      @size += 1
    end

    if newer
      node.term = new_term
      new_term._prev = old_term
    end

    node.edits << new_term
    newer
  end

  # save to disk, return old entry if exists
  def set!(new_term : VpTerm) : Bool
    line = "\n#{new_term}"

    File.write(@file, line, mode: "a")
    File.write(@flog, line, mode: "a") if new_term.mtime > 0

    set(new_term)
  end

  def find(key : String) : VpTerm?
    @trie.find(key).try(&.term)
  end

  def find!(key : String) : VpTerm
    find(key) || gen_term(key, [""])
  end

  delegate scan, to: @trie
  delegate to_a, to: @trie

  def each : Nil
    @trie.each do |node|
      if term = node.term
        yield term
      end
    end
  end

  def full_each : Nil
    @trie.each do |node|
      node.edits.each { |term| yield term }
    end
  end

  def save!(prune : Bool = false) : Nil
    # TODO: remove duplicate entries

    ::FileUtils.mkdir_p(File.dirname(@file))

    @data.sort_by! { |x| {x.mtime, x.key.size, x.key} }
    @data.uniq! { |x| {x.key, x.uname, x.val, x.attr, x.rank} }

    tspan = Time.measure do
      File.open(@file, "w") do |io|
        @data.each { |term| io.puts(term) }
      end

      logs = @data.select(&.mtime.> 0)

      if logs.empty?
        File.delete(@flog) if File.exists?(@flog)
      else
        File.open(@flog, "w") do |io|
          logs.each { |term| io.puts(term) }
        end
      end
    end

    puts "- <vp_dict> [#{File.basename(@file)}] saved: #{@size} entries, \
          time: #{tspan.total_milliseconds.round.to_i}ms".colorize.yellow
  end
end
