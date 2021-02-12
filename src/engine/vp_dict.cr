require "colorize"
require "file_utils"

require "./vp_dict/*"

class CV::VpDict
  DIR = "_db/dictdb/active"

  ::FileUtils.mkdir_p("#{DIR}/common")
  ::FileUtils.mkdir_p("#{DIR}/lookup")
  ::FileUtils.mkdir_p("#{DIR}/system")
  ::FileUtils.mkdir_p("#{DIR}/unique")

  class_getter trungviet : self { load("trungviet") }
  class_getter cc_cedict : self { load("cc_cedict") }
  class_getter trich_dan : self { load("trich_dan") }

  class_getter tradsim : self { load("tradsim") }
  class_getter binh_am : self { load("binh_am") }
  class_getter hanviet : self { load("hanviet") }

  class_getter regular : self { load("regular") }
  class_getter various : self { load("various") }
  class_getter suggest : self { load("suggest") }

  CACHE = {} of String => self

  def self.load(dname : String, reset : Bool = false)
    CACHE[dname] ||=
      case dname
      when "trungviet", "cc_cedict", "trich_dan"
        new(path("lookup/#{dname}"), dtype: 1, p_min: 4, reset: reset)
      when "tradsim", "binh_am", "hanviet"
        new(path("system/#{dname}"), dtype: 2, p_min: 3, reset: reset)
      when "regular", "suggest", "various"
        new(path("common/#{dname}"), dtype: 2, p_min: 2, reset: reset)
      else
        new(path("unique/#{dname}"), dtype: 3, p_min: 1, reset: reset)
      end
  end

  def self.path(label : String)
    File.join(DIR, "#{label}.tsv")
  end

  #########################

  getter file : String
  getter flog : String

  getter trie = VpTrie.new
  getter logs = [] of VpTerm

  getter size = 0

  getter dtype : Int32 # dict type
  getter p_min : Int32 # minimal user power required

  def initialize(@file : String, @dtype = 0, @p_min = 1, reset = false)
    @flog = @file.sub(".tsv", ".tab")
    load!(@file) unless reset || !File.exists?(@file)
  end

  def load!(file : String) : Nil
    count = 0

    tspan = Time.measure do
      File.each_line(file) do |line|
        next if line.strip.blank?

        cols = line.split('\t')
        add(VpTerm.new(cols, @dtype, @p_min))

        count += 1
      rescue err
        puts "<vp_dict> [#{file}] error on `#{line}`: #{err}]".colorize.red
      end
    end

    puts "- <vp_dict> [#{file}] loaded: #{count} lines, \
          time: #{tspan.total_milliseconds.round.to_i}ms".colorize.green
  end

  # return true if new term prevails
  def add(new_term : VpTerm) : Bool
    @logs << new_term if new_term.mtime > 0

    # find existing node or force creating new one
    node = @trie.find!(new_term.key)

    if old_term = node.term
      newer = new_term.beats?(old_term)
    else
      newer = new_term.power >= @p_min
      @size += 1
    end

    if newer
      node.term = new_term
      node.edits.reject!(&.uname.== new_term.uname)
    end

    node.edits << new_term
    newer
  end

  # save to disk, return old entry if exists
  def add!(new_term : VpTerm) : Bool
    line = "\n#{new_term}"
    File.write(@file, line, mode: "a")
    File.write(@flog, line, mode: "a") if new_term.mtime > 0

    add(new_term)
  end

  def find(key : String) : VpTerm?
    @trie.find(key).try(&.term)
  end

  delegate scan, to: @trie
  delegate to_a, to: @trie

  def save!(trim : Bool = false) : Nil
    ::FileUtils.mkdir_p(File.dirname(@file))

    tspan = Time.measure do
      File.open(@file, "w") do |io|
        @trie.each(full: !trim) { |term| io.puts(term) }
      end

      next if @dtype < 2

      File.open(@flog, "w") do |io|
        @logs.each { |term| io.puts(term) }
      end
    end

    puts "- <vp_dict> [#{File.basename(@afile)}] saved: #{@size} entries, \
          time: #{tspan.total_milliseconds.round.to_i}ms".colorize.yellow
  end
end
