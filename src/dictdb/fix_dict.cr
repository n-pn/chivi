require "colorize"
require "file_utils"

# dict with fixed content, like cc_cedict or trungviet
class FixDict
  SEP0 = "ǁ"
  SEP1 = "¦"

  class Node
    getter key : String
    property val = ""
    getter trie = {} of Char => Node

    def initialize(@key)
    end

    def to_s(io : IO)
      io << key << SEP0 << val
    end

    def to_s
      String.build { |io| to_s(io) }
    end
  end

  getter file : String
  getter time = Time.utc

  getter data = Node.new("")
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

  def load!(file : String = @file) : Void
    count = 0

    elapsed_time = Time.measure do
      File.each_line(file) do |line|
        key, val = line.split(SEP0, 2)
        set(key, val)
        count += 1
      rescue
        puts "- <fix_dict> error parsing line `#{line}`.".colorize(:red)
      end
    end

    puts "- <fix_dict> [#{file.colorize(:yellow)}] loaded, \
    lines: #{count.colorize(:yellow)}, \
    time: #{elapsed_time.total_milliseconds.colorize(:yellow)}ms"

    self.time = File.info(file).modification_time
  end

  def set!(key : String, val : String, mode = :old_first) : Void
    set(key, val)
    File.open(@file, "a") { |io| io << key << SEP0 << val << "\n" }
  end

  def set(key : String, val : String, mode = :old_first) : Void
    node = @data
    key.each_char do |char|
      node = node.trie[char] ||= Node.new(node.key + char)
    end

    @size -= 1 if val.empty?

    if node.val.empty?
      node.val = val
      @size += 1
    elsif val.empty?
      node.val = val if mode == :keep_new
    else
      case mode
      when :keep_old
        # do nothing
      when :keep_new
        # overwrite old val
        node.val = val
      when :new_first
        # put new val at first
        node.val = join_val(val, node.val)
      else # :old_first
        # put new val at last
        node.val = join_val(node.val, val)
      end
    end
  end

  def join_val(val1 : String, val2 : String)
    val1.split(SEP1).concat(val2.split(SEP1)).uniq.join(SEP1)
  end

  def del!(key : String)
    set!(key, "", mode: :keep_new)
  end

  def []?(key : String)
    get(key)
  end

  def get(key : String) : Node?
    node = @data

    key.each_char do |char|
      node = node.trie[char]?
      return nil unless node
    end

    node unless node.val.empty?
  end

  def has_key?(key : String) : Bool
    get(key) != nil
  end

  def scan(input : String, skip : Int32 = 0)
    scan(input.chars, skip) do |item|
      yield item
    end
  end

  def scan(chars : Array(Char), skip : Int32 = 0)
    node = @data

    skip.upto(chars.size - 1) do |idx|
      break unless node = node.trie[chars[idx]]?
      yield node unless node.val.empty?
    end
  end

  include Enumerable(Node)

  def each
    queue = [@data]

    while node = queue.pop?
      node.trie.each_value do |node|
        queue << node
        yield node unless node.val.empty?
      end
    end
  end

  def save!(file : String = @file) : Void
    File.open(file, "w") do |io|
      each { |node| io.puts node }
    end

    puts "- Saved `#{file.colorize(:yellow)}`, \
            entries: #{@size.colorize(:yellow)}"
  end

  # Class methods

  CACHE = {} of String => FixDict

  def load(file : String, preload : Bool = true) : FixDict
    CACHE[file] ||= new(file, preload)
  end

  def cached
    CACHE
  end

  LOOKUP_DIR = File.join("var", "libcv", "lookup")
  FileUtils.mkdir_p(LOOKUP_DIR)

  def lookup_path(name : String)
    File.join(LOOKUP_DIR, "#{name}.dic")
  end
end

# test = FixDict.new("tmp/test_fix_dict.dic", preload: true)

# test.set("a", "a")
# test.set!("a", "b")

# puts test.get("a")

# test.set("b", "b")
# test.set("abc", "abc")
# test.set("bc", "bc")

# test.scan("abc".chars, skip: 1) do |item|
#   puts item
# end

# puts test.get("xy")

# test.save!

# test.set!("xx", "yy")
# test.del!("xy")
