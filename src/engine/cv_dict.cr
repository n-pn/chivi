require "colorize"
require "file_utils"

# main dict entries
# TODO: redname?
class CvDict
  SEP_0 = "ǁ"
  SEP_1 = "¦"

  class Node
    def self.parse(line : String, sep_0 : String = SEP_0, sep_1 : String | Regex = SEP_1)
      cols = line.split(sep_0)

      key = cols[0]
      vals = cols.fetch(1, "").split(sep_1)
      extra = cols.fetch(2, "")

      {key, vals, extra}
    end

    getter key : String
    property vals : Array(String)
    property extra : String
    # extra data, can be used to mark attributes or priorities

    getter trie = Hash(Char, Node).new

    def initialize(@key, @vals = [] of String, @extra = "")
    end

    def to_s
      String.build { |io| to_s(io) }
    end

    def to_s(io : IO, trim = 4)
      vals = @vals.uniq
      vals = vals.last(trim) if trim > 0

      io << @key << SEP_0
      vals.join(io, SEP_1)
      io << SEP_0 << @extra
    end

    def puts(io : IO, trim = 4)
      to_s(io, trim)
      io << "\n"
    end

    def remove!
      @vals.clear
    end

    def removed?
      @vals.empty?
    end

    def each
      queue = [self]

      while node = queue.pop?
        node.trie.each_value do |node|
          queue << node
          yield node unless node.removed?
        end
      end
    end

    def to_a
      res = [] of Node
      each { |node| res << node }
      res
    end

    def find!(key : String) : Node
      node = self

      key.each_char do |char|
        node = node.trie[char] ||= Node.new(node.key + char)
      end

      node
    end

    def find!(key : Array(Char), from = 0) : Node
      node = self

      from.upto(key.size - 1) do |idx|
        char = key.unsafe_fetch(idx)
        node = node.trie[char] ||= Node.new(node.key + char)
      end

      node
    end

    def find(key : String) : Node?
      node = self

      key.each_char do |char|
        return nil unless node = node.trie[char]?
      end

      node unless node.removed?
    end

    def find(key : Array(Char), from = 0) : Node?
      node = self

      from.upto(key.size - 1) do |idx|
        char = key.unsafe_fetch(idx)
        return nil unless node = node.trie[char]?
      end

      node unless node.removed?
    end

    def has_key?(key : String) : Bool
      find(key) != nil
    end

    def scan(chars : Array(Char), from = 0) : Void
      node = self

      from.upto(chars.size - 1) do |idx|
        char = chars.unsafe_fetch(idx)
        return unless node = node.trie[char]?
        yield node unless node.removed?
      end
    end

    def scan(input : String, from = 0) : Void
      scan(input.chars, from) { |node| yield node }
    end
  end

  getter file : String
  getter time = Time.utc(2020, 1, 1)

  getter root = Node.new("")
  getter size = 0

  def initialize(@file, preload : Bool = false)
    load!(@file) if preload && exists?
  end

  def time=(time : Time)
    @time = time if @time < time
  end

  def exists?
    File.exists?(@file)
  end

  def load!(file : String = @file, sep_0 : String = SEP_0, sep_1 : String | Regex = SEP_1) : Void
    count = 0

    elapsed_time = Time.measure do
      File.each_line(file) do |line|
        key, vals, extra = Node.parse(line, sep_0, sep_1)
        upsert(key, vals, extra)
        count += 1
      rescue
        puts "- <cv_dict> error parsing line `#{line}`.".colorize(:red)
      end
    end

    elapse_time = elapsed_time.total_milliseconds.round.to_i
    puts "- <cv_dict> [#{file.colorize(:yellow)}] loaded, \
            lines: #{count.colorize(:yellow)}, \
            time: #{elapse_time.colorize(:yellow)}ms"

    self.time = File.info(file).modification_time
  end

  def delete!(key : String)
    append!(delete(key))
  end

  def delete(key : String)
    upsert(key, &.vals.push(""))
  end

  def upsert!(key : String, value : String, extra = "")
    append!(upsert(key, value, extra))
  end

  def upsert!(key : String, vals : Array(String), extra = "")
    append!(upsert(key, vals, extra))
  end

  def upsert!(key : String)
    node = upsert(key) { |node| yield node }
    append!(node)
  end

  def append!(node : Node, trim = 1) : Node
    File.open(@file, "a") { |io| node.puts(io, trim: trim) }
    node
  end

  def upsert(key : String, value : String = "", extra = "")
    upsert(key) do |node|
      node.vals = [value]
      node.extra = extra
    end
  end

  def upsert(key : String, vals : Array(String), extra = "") : Node
    upsert(key) do |node|
      node.vals = vals
      node.extra = extra
    end
  end

  def upsert(key : String) : Node
    node = @root.find!(key)

    @size += 1 if node.removed?
    yield node
    @size -= 1 if node.removed?
    node
  end

  include Enumerable(Node)
  delegate each, to: @root
  delegate scan, to: @root
  delegate find, to: @root
  delegate has_key?, to: @root

  def save!(file : String = @file, trim = 0) : Void
    File.open(file, "w") do |io|
      each { |node| node.puts(io, trim: trim) }
    end

    puts "- <cv_dict> [#{file.colorize(:yellow)}] saved, entries: #{@size.colorize(:yellow)}."
  end

  # class methods

  DIR = File.join("var", "dict_files")
  FileUtils.mkdir_p(File.join(DIR, "lookup"))
  FileUtils.mkdir_p(File.join(DIR, "unique"))

  def self.path_for(dname : String)
    File.join(DIR, "#{dname}.dic")
  end

  @@cc_cedict : CvDict? = nil
  @@trungviet : CvDict? = nil
  @@hanviet : CvDict? = nil
  @@generic : CvDict? = nil

  def self.cc_cedict
    @@cc_cedict ||= new(path_for("cc_cedict"), true)
  end

  def self.trungviet
    @@trungviet ||= new(path_for("cc_cedict"), true)
  end

  def self.hanviet
    @@hanviet ||= load_shared("hanviet")
  end

  def self.generic
    @@generic ||= load_shared("generic")
  end

  CACHE = {} of String => self

  def self.load(file : String, preload : Bool = true) : self
    CACHE[file] ||= new(file, preload)
  end

  def self.load_legacy(file : String)
    dict = new(file, preload: false)
    dict.tap(&.load!(file, "=", /[\/|]/))
  end

  def self.load_shared(dname : String)
    load(path_for("shared/#{dname}"), true)
  end

  def self.load_unique(dname : String)
    load(path_for("unique/#{dname}"), true)
  end

  def self.load_remote(dname : String)
    case dname
    when "hanviet" then hanviet
    when "generic" then generic
    when "pinyins", "tradsim", "combine", "suggest"
      load_shared(dname)
    else
      load_unique(dname)
    end
  end

  def self.for_convert(dname = "combine")
    special = dname == "combine" ? load_shared(dname) : load_unique(dname)
    {hanviet, generic, special}
  end
end

# test = CvDict.new("tmp/test_lex_dict.dic", preload: true)

# test.upsert("a", "a")
# test.upsert!("a", "b")

# puts test.find("a")

# test.upsert("b", "b")
# test.upsert("abc", "abc")
# test.upsert("bc", "bc")

# test.scan("abc".chars, from: 1) do |item|
#   puts item
# end

# test.scan("abcxyz".chars, from: 1) do |item|
#   puts item.to_s
# end

# test.save!(trim: 1)

# puts test.find("xy")
# puts test.find("xcbsf")

# test.upsert!("xx", "yy")
# test.delete!("xy")

# puts test.size

# test.upsert("xx") do |node|
#   node.vals.clear
# end

# puts test.size
