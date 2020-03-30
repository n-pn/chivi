require "time"
require "colorize"

class CDict
  # Child
  class Item
    EPOCH = Time.utc(2020, 1, 1)

    SEP_0 = "ǁ"
    SEP_1 = "¦"

    getter key : String
    getter vals : Array(String)
    getter mtime : Time? = nil

    def initialize(line : String)
      cols = line.split(SEP_0)

      @key = cols[0]
      @vals = (cols[1]? || "").split(SEP_1)

      mtime = cols[2]?.try(&.to_i?) || 0
      @mtime = EPOCH + mtime.minutes
    end

    def initialize(@key : String, vals : String, @mtime = nil)
      @vals = vals.split(SEP_1)
    end

    def initialize(@key : String, @vals : Array(String), @mtime = nil)
    end

    def to_s(io : IO)
      io << @key << SEP_0 << @vals.join(SEP_1)
      if mtime = @mtime
        io << SEP_0 << (mtime - EPOCH).total_minutes.to_i
      end
    end
  end

  class Node
    alias Trie = Hash(Char, Node)

    property item : Item?
    property trie : Trie

    def initialize(@item : Item? = nil)
      @trie = Trie.new
    end
  end

  # Class

  @@cache = {} of String => CDict

  def self.load(file : String, reload : Bool = false) : CDict
    dict = @@cache[file]?
    return dict if dict && !reload
    @@cache[file] = new(file, preload: true)
  end

  def self.load!(file : String, reload = false)
    raise "File [#{file.colorize(:red)}] not found!" unless File.exists?(file)
    load(file, reload: reload)
  end

  getter file : String
  getter trie : Node = Node.new
  getter size : Int32 = 0
  getter mtime : Time = Time.utc

  def initialize(@file : String, preload : Bool = true)
    if File.exists?(@file)
      @mtime = File.info(@file).modification_time
      load!(@file) if preload
    end
  end

  def load!(file : String = @file) : CDict
    time1 = Time.monotonic
    lines = File.read_lines(file)
    lines.each { |line| put(Item.new(line)) }
    time2 = Time.monotonic

    elapsed = (time2 - time1).total_milliseconds
    puts "- Loaded [#{file.colorize(:yellow)}], lines: #{lines.size.colorize(:yellow)}, time: #{elapsed.colorize(:yellow)}ms"

    self
  end

  def set(key : String, vals : String | Array(String))
    item = Item.new(key, vals, Time.utc)
    File.open(@file, "a") { |f| f.puts item }
    put(item)
  end

  def del(key : String)
    set(key, [] of String)
  end

  def put(key : String, vals : String | Array(String))
    put(Item.new(key, vals))
  end

  def put(new_item : Item) : Item?
    node = new_item.key.chars.reduce(@trie) do |node, char|
      node.trie[char] ||= Node.new
    end

    old_item = node.item
    node.item = new_item

    @size += 1 if old_item.nil?
    old_item
  end

  def find(key : String) : Item?
    node = @trie

    key.chars.each do |char|
      node = node.trie[char]?
      return nil unless node
    end

    node.item
  end

  def scan(chars : Array(Char) | String, offset : Int32 = 0)
    res = [] of Item

    node = @trie
    offset.upto(chars.size - 1) do |idx|
      char = chars[idx]
      break unless node = node.trie[char]?
      if item = node.item
        res << item
      end
    end

    res
  end

  def includes?(key)
    find(key) != nil
  end

  def []?(key)
    find(key)
  end

  def []=(key : String, val : String | Array(String))
    put(key, val)
  end

  include Enumerable(Item)

  def each
    queue = [@trie]
    while node = queue.pop?
      node.trie.each_value do |node|
        queue << node
        if item = node.item
          yield item
        end
      end
    end
  end

  def save!(file : String = @file)
    File.open(file, "w") do |f|
      each { |item| f.puts item }
    end

    puts "- Saved [#{file.colorize(:yellow)}], items: #{@size.colorize(:yellow)}"
  end
end
