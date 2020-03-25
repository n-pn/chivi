require "time"
require "colorize"

class Engine
  class DictItem
    EPOCH = Time.utc(2020, 1, 1)

    SEP_0 = "ǁ"
    SEP_1 = "¦"

    getter key : String
    property vals : Array(String)
    property mtime : Time? = nil

    def initialize(line : String)
      cols = line.split(SEP_0)

      @key = cols[0]
      @vals = (cols[1]? || "").split(SEP_1)

      if mtime = cols[2]?
        mtime = mtime.try &.to_i || 0
        @mtime = EPOCH + mtime.minutes
      end
    end

    def initialize(@key : String, val : String, @mtime = nil)
      @vals = val.split(SEP_1)
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

  class DictNode
    alias Trie = Hash(Char, DictNode)

    property item : DictItem?
    property trie : Trie

    def initialize(@item : DictItem? = nil)
      @trie = Trie.new
    end
  end

  class DictFile
    # Class

    @@cache = {} of String => DictFile

    def self.load(file : String, reload : Bool = false) : DictFile
      if dict = @@cache[file]?
        return dict unless reload
      end
      @@cache[file] = new(file, preload: true)
    end

    def self.load!(file : String, reload = false)
      raise "File [#{file.colorize(:red)}] not found!" unless File.exists?(file)
      load(file, reload: reload)
    end

    def self.mtime(time = Time.utc) : Int32
      (time - EPOCH).total_minutes.to_i
    end

    # Instance

    getter file : String
    getter trie : DictNode = DictNode.new
    getter size : Int32 = 0
    getter mtime : Time = Time.local

    def initialize(@file : String, preload = true)
      if File.exists?(@file)
        @mtime = File.info(@file).modification_time
        load!(@file) if preload
      end
    end

    def load!(file : String = @file) : DictFile
      time1 = Time.monotonic
      lines = File.read_lines(file)
      lines.each { |line| put(DictItem.new(line)) }
      time2 = Time.monotonic

      elapsed = (time2 - time1).total_milliseconds
      puts "- Loaded [#{file.colorize(:yellow)}], lines: #{lines.size.colorize(:yellow)}, time: #{elapsed.colorize(:yellow)}ms"

      self
    end

    def set(key : String, val : String)
      item = DictItem.new(key, val, Time.utc)
      File.open(@file, "a") { |f| f.puts item }
      put(item)
    end

    def del(key : String)
      set(key, "")
    end

    def put(key : String, val : String | Array(String))
      put(DictItem.new(key, val))
    end

    def put(item : DictItem)
      @size += 1 unless item.vals.empty?
      old_val = [] of String

      node = item.key.chars.reduce(@trie) do |node, char|
        node.trie[char] ||= DictNode.new
      end

      if old = node.item
        old_vals = old.vals
        old.vals = item.vals
        old.mtime = item.mtime
        @size -= 1 unless old_vals.empty?
      else
        node.item = item
      end

      old_vals
    end

    def find(key : String) : DictItem?
      node = @trie

      key.chars.each do |char|
        node = node.trie[char]?
        return nil unless node
      end

      node.item
    end

    def scan(chars : Array(Char), offset : Int32 = 0)
      output = [] of DictItem

      node = @trie
      chars[offset..-1].each do |char|
        if node = node.trie[char]?
          if item = node.item
            output << item
          end
        else
          break
        end
      end

      output
    end

    include Enumerable(DictItem)

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

      puts "- Save to [#{file.colorize(:yellow)}], items: #{@size.colorize(:yellow)}"
    end
  end
end
