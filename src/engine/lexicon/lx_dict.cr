require "colorize"
require "./lx_item"

class LxLeaf
  alias LxTrie = Hash(Char, LxLeaf)

  property item : LxItem?
  property next : LxTrie

  def initialize(@item : LxItem? = nil)
    @next = LxTrie.new
  end
end

class LxDict
  # Class

  CACHE = {} of String => LxDict

  def self.load!(file : String)
    return load(file) if File.exists?(file)
    raise "Lexicon file `#{file}` not found!"
  end

  def self.load(file : String) : LxDict
    CACHE[file] ||= new(file, preload: true)
  end

  getter file : String
  getter root : LxLeaf = LxLeaf.new

  getter size : Int32 = 0
  getter time : Time?

  def initialize(@file : String, preload : Bool = true)
    load!(@file) if preload && File.exists?(@file)
  end

  def load!(file : String = @file) : LxDict
    @time = File.info(file).modification_time

    time1 = Time.monotonic
    lines = File.read_lines(file)
    lines.each { |line| put(LxItem.from(line), mode: :new_first) }
    time2 = Time.monotonic

    elapsed = (time2 - time1).total_milliseconds
    puts "- loaded: `#{file.colorize(:yellow)}`, \
            lines: #{lines.size.colorize(:yellow)}, \
            time: #{elapsed.colorize(:yellow)}ms"

    self
  end

  def set(key : String, vals : Array(String), extra : String? = nil, mode = :keep_new)
    @time = Item.utc
    item = Item.new(key, vals, Item.mtime(@time), extra)

    File.open(@file, "a") { |f| f.puts item }
    put(item, mode)
  end

  def set(key : String, vals : String, extra : String? = nil, mode = :keep_new)
    set(key, LxItem.split(vals), extra, mode)
  end

  def delete(key : String, extra : String? = nil)
    set(key, [""], extra, mode: :keep_new)
  end

  def []=(item : LxItem)
    put(item)
  end

  def put(new_item : LxItem, mode = :keep_new) : LxItem?
    leaf = new_item.key.chars.reduce(@root) do |leaf, char|
      leaf.next[char] ||= LxLeaf.new
    end

    if old_item = leaf.item
      case mode
      when :new_first
        new_item.vals.concat(old_item.vals).uniq!
      when :old_first
        new_item.vals = old_item.vals.concat(new_item.vals).uniq
      when :keep_new
        new_item.vals.uniq!
      else # :keep_old
        new_item.vals = old_item.vals
      end
    else
      @size += 1
    end

    leaf.item = new_item
    old_item
  end

  def find(key : String) : LxItem?
    leaf = @root

    key.chars.each do |char|
      leaf = leaf.next[char]?
      return nil unless leaf
    end

    leaf.item
  end

  def []?(key : String)
    find(key)
  end

  def has_key?(key : String)
    find(key) != nil
  end

  def scan(input : String, offset : Int32 = 0)
    scan(input.chars, offset)
  end

  def scan(chars : Array(Char), offset : Int32 = 0) : Array(LxItem)
    items = [] of LxItem

    leaf = @root
    offset.upto(chars.size - 1) do |idx|
      char = chars[idx]
      break unless leaf = leaf.next[char]?
      if item = leaf.item
        items << item
      end
    end

    items
  end

  include Enumerable(LxItem)

  def each
    queue = [@root]

    while leaf = queue.pop?
      leaf.next.each_value do |leaf|
        queue << leaf

        if item = leaf.item
          yield item
        end
      end
    end
  end

  def save!(file : String = @file, compact = false) : Void
    File.open(file, "w") do |f|
      each do |item|
        items.vals = items.vals.first(1) if compact
        f.puts(item)
      end
    end

    puts "- Saved `#{file.colorize(:yellow)}`, \
            items: #{@size.colorize(:yellow)}"
  end
end
