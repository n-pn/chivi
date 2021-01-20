require "colorize"
require "file_utils"

require "./vp_dict/*"

class CV::VpDict
  DIR = "_db/dictdb/active"
  ::FileUtils.mkdir_p(DIR)

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

  def self.load(dname : String, regen : Bool = false)
    CACHE[dname] ||=
      case dname
      when "trungviet", "cc_cedict", "trich_dan"
        new("lookup/#{dname}", dtype: 1, p_min: 4, regen: regen)
      when "tradsim", "binh_am", "hanviet"
        new("system/#{dname}", dtype: 2, p_min: 3, regen: regen)
      when "regular", "suggest", "various"
        new("common/#{dname}", dtype: 2, p_min: 2, regen: regen)
      else
        new("unique/#{dname}", dtype: 3, p_min: 1, regen: regen)
      end
  end

  #########################

  getter afile : String # dict file for auto generated content
  getter efile : String # dict file for user submitted content

  getter dtype : Int32         # dict type
  getter p_min : Int32         # minimal user power required
  getter mtime : Int64 = 0_i64 # dict's modification time

  # all existing entries
  getter items = [] of Tuple(VpEntry, VpEmend?)
  # fast trie lookup for newest entries
  getter _root = Node.new
  # count all newest entries
  getter rsize : Int32 = 0

  def initialize(label : String, @dtype = 0, @p_min = 1, regen : Bool = false)
    @afile = "#{DIR}/#{label}.tsv"
    @efile = "#{DIR}/#{label}.tab"

    unless regen
      load!(@afile) if File.exists?(@afile)
      load!(@efile) if File.exists?(@efile)
    end
  end

  def load!(file : String) : Nil
    count = 0

    tspan = Time.measure do
      File.each_line(file) do |line|
        next if line.strip.blank?
        upsert(line.split('\t'))
        count += 1
      rescue err
        puts "<vp_dict> [#{file}] error on `#{line}`: #{err}]".colorize.red
      end
    end

    puts "<vp_dict> [#{file}] loaded: #{count} lines, \
          time: #{tspan.total_milliseconds.round.to_i}ms".colorize.green
    bump_mtime!(File.info(file).modification_time)
  end

  def to_str(io : IO, entry : VpEntry, emend : VpEmend?) : Nil
    if emend
      entry.to_s(io)
      io << '\t'
      emend.to_s(io)
    else
      entry.to_str(io)
    end
  end

  # save to disk, return old entry if exists
  def upsert!(entry : VpEntry, emend : VpEmend? = nil) : Bool
    File.open(emend ? @efile : @afile, "a") do |io|
      io << '\n'
      to_str(io, entry, emend)
    end

    bump_mtime!(emend.rtime) if emend
    upsert(entry, emend)
  end

  def upsert(cols : Array(String))
    entry = VpEntry.from(cols, dtype: @dtype)
    emend = VpEmend.from(cols, p_min: @p_min)

    upsert(entry, emend)
  end

  # return old entry if exists
  def upsert(new_entry : VpEntry, new_emend : VpEmend? = nil) : Bool
    @items << {new_entry, new_emend}

    # find existing node or force creating new one
    node = @_root.find!(new_entry.key)

    # old_power = node.emend.try(&.power) || @p_min
    # old_mtime = node.emend.try(&.mtime) || 0

    if old_entry = node.entry
      newer = new_emend ? new_emend.newer?(node.emend) : false

      if newer
        node.entry = new_entry
        node._hint.concat(old_entry.vals).uniq!
        node.emend = new_emend
      else
        node._hint.concat(new_entry.vals).uniq!
      end

      return newer
    end

    if new_emend.try(&.power.< p_min)
      node._hint.concat(new_entry.vals)
      return false
    end

    @rsize += 1
    node.entry = new_entry
    node.emend = new_emend
    true
  end

  def bump_mtime!(time : Time)
    mtime = time.to_unix
    @mtime == mtime if @mtime < mtime
  end

  def find(key : String) : VpEntry?
    @_root.find(key).try(&.entry)
  end

  def info(key : String)
    return unless node = @_root.find(key)
    return unless entry = node.entry

    {
      key:   entry.key,
      vals:  entry.vals,
      attrs: entry.attrs,
      hints: node._hint,
      mtime: node.emend.try(&.rtime.to_unix_ms),
      uname: node.emend.try(&.uname),
      power: node.emend.try(&.power),
    }
  end

  def scan(chars : Array(Char), idx : Int32 = 0) : Nil
    node = @_root
    idx.upto(chars.size - 1) do |i|
      char = chars.unsafe_fetch(i)
      break unless node = node._trie[char]?
      node.entry.try { |x| yield x }
    end
  end

  def newest
    output = [] of Tuple(VpEntry, VpEmend?)

    @_root.each do |node|
      output << {node.entry.not_nil!, node.emend} if node.entry
    end

    output
  end

  def save!(trim : Bool = false) : Nil
    ::FileUtils.mkdir_p(File.dirname(@afile))

    tspan = Time.measure do
      entry_io = File.open(@afile, "w")
      emend_io = File.open(@efile, "w")

      data = trim ? newest : @items
      data.each do |entry, emend|
        io = emend ? emend_io : entry_io
        to_str(io, entry, emend)
        io << '\n'
      end

      entry_io.close
      emend_io.close
    end

    count = trim ? @items.size : @rsize
    puts "<vp_dict> [#{File.basename(@afile)}] saved: #{count} entries, \
          time: #{tspan.total_milliseconds.round.to_i}ms".colorize.yellow
  end

  #########################

  class Node
    alias Trie = Hash(Char, Node)

    property entry : VpEntry?
    property emend : VpEmend?

    getter _hint : Array(String) { [] of String }
    getter _trie : Trie

    def initialize(@entry = nil, @emend = nil, @_trie = Trie.new)
    end

    def find!(key : String) : Node
      node = self
      key.each_char { |c| node = node._trie[c] ||= Node.new }
      node
    end

    def find(key : String) : Node?
      node = self
      key.each_char { |c| return unless node = node._trie[c]? }
      node
    end

    def each : Nil
      queue = [self]

      while node = queue.pop?
        node._trie.each_value do |node|
          queue << node
          yield node if node.entry
        end
      end
    end
  end
end
