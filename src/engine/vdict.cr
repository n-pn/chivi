require "colorize"
require "file_utils"

require "./vdict/*"

class CV::Vdict
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
        new(path("system/#{dname}"), dtype: 1_i8, p_min: 4_i8, reset: reset)
      when "tradsim", "binh_am", "hanviet"
        new(path("system/#{dname}"), dtype: 2_i8, p_min: 3_i8, reset: reset)
      when "regular", "suggest", "various"
        new(path("common/#{dname}"), dtype: 2_i8, p_min: 2_i8, reset: reset)
      else
        new(path("unique/#{dname}"), dtype: 3_i8, p_min: 1_i8, reset: reset)
      end
  end

  def self.path(label : String)
    File.join(DIR, "#{label}.tsv")
  end

  #########################

  getter file : String
  getter ftab : String

  getter trie = Vtrie.new
  getter logs = [] of Vterm

  getter size = 0

  getter dtype : Int8 # dict type
  getter p_min : Int8 # minimal user power required

  def initialize(@file : String, @dtype = 0_i8, @p_min = 1_i8, reset = false)
    @ftab = @file.sub(".tsv", ".tab")
    load!(@file) unless reset || !File.exists?(@file)
  end

  def load!(file : String) : Nil
    count = 0

    tspan = Time.measure do
      File.each_line(file) do |line|
        next if line.strip.blank?

        cols = line.split('\t')
        upsert(Vterm.new(cols, @dtype, @p_min))

        count += 1
      rescue err
        puts "<vdict> [#{file}] error on `#{line}`: #{err}]".colorize.red
      end

      # remove duplicate entries
      @trie.each { |node| node.prune! }
    end

    puts "- <vdict> [#{file}] loaded: #{count} lines, \
          time: #{tspan.total_milliseconds.round.to_i}ms".colorize.green
  end

  def upsert(key : String, vals : Array(String), prio = 1_i8, attr = 0_i8)
    upsert(gen_term(key, vals, prio, attr))
  end

  def gen_term(key : String, vals = [""], prio = 1_i8, attr = 0_i8)
    Vterm.new(
      key, vals, prio: prio, attr: attr,
      mtime: 0, dtype: @dtype, power: @p_min)
  end

  # return true if new term prevails
  def upsert(new_term : Vterm) : Bool
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
      new_term._prev = old_term
    end

    node.edits << new_term
    newer
  end

  # save to disk, return old entry if exists
  def upsert!(new_term : Vterm) : Bool
    line = "\n#{new_term}"

    File.write(@file, line, mode: "a")
    File.write(@ftab, line, mode: "a") if new_term.mtime > 0

    upsert(new_term)
  end

  def find(key : String) : Vterm?
    @trie.find(key).try(&.term)
  end

  def find!(key : String) : Vterm
    find(key) || gen_term(key, [""])
  end

  delegate scan, to: @trie
  delegate to_a, to: @trie

  def each(full : Bool = true) : Nil
    @trie.each do |node|
      if full
        node.edits.each { |term| yield term }
      elsif term = node.term
        yield term
      end
    end
  end

  def save!(prune : Bool = true) : Nil
    ::FileUtils.mkdir_p(File.dirname(@file))

    tspan = Time.measure do
      File.open(@file, "w") do |io|
        @trie.each do |node|
          node.prune! if prune
          node.edits.each { |term| io.puts(term) }
        end
      end

      @logs.uniq! { |x| {x.mtime, x.uname} } if prune

      if @logs.empty?
        File.delete(@ftab) if File.exists?(@ftab)
      else
        File.open(@ftab, "w") do |io|
          @logs.sort_by!(&.mtime).each { |term| io.puts(term) }
        end
      end
    end

    puts "- <vdict> [#{File.basename(@file)}] saved: #{@size} entries, \
          time: #{tspan.total_milliseconds.round.to_i}ms".colorize.yellow
  end
end
