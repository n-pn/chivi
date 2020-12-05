require "colorize"

class Chivi::Lexicon
  SEP = "ǀ"

  class Item
    EPOCH = Time.utc(2020, 1, 1)

    def self.mtime(rtime = Time.utc)
      (rtime - EPOCH).total_minutes.round.to_i
    end

    def self.parse(line : String, dlock : Int32 = 1)
      cols = line.split('\t')

      key = cols[0]
      vals = (cols[1]? || "").split(SEP)
      attr = cols[2]? || ""

      new(key, vals, attr).tap do |this|
        if this.mtime = cols[3]?.try(&.to_i?)
          this.uname = cols[4]? || "<init>"
          this.plock = cols[5]?.try(&.to_i?) || dlock
        end
      end
    end

    getter key : String           # primary key
    property vals : Array(String) # primary values
    property attr : String = ""   # for extra attributes

    property mtime : Int32 = 0   # modification time
    property uname : String = "" # username
    property plock : Int32 = 1   # permission lock

    def initialize(@key, @vals, @attr = "")
    end

    def empty?
      @vals.empty? || @vals.first.empty?
    end

    def blank?
      empty? && @attr.empty?
    end

    def track?
      @mtime > 0
    end

    def rtime
      EPOCH + @mtime.minutes
    end

    def merge!(other : self) : Nil
      return if @plock > other.plock

      if @plock == other.plock
        return if @mtime > other.mtime
      else
        @plock = other.plock
      end

      @vals = (other.vals + vals).uniq!
      @attr = other.attr

      @mtime = other.mtime
      @uname = other.uname
    end

    def clear! : Void
      @vals.empty
      @attr = ""
      @mtime = 0
    end

    def println(io : IO, dlock = 1) : Nil
      return if @vals.empty?

      io << key << '\t' << @vals.join(SEP)

      if @mtime > 0
        io << '\t' << @attr << '\t' << @mtime << '\t' << @uname
        io << '\t' << @plock if @plock != dlock
      elsif !attr.empty?
        io << '\t' << @attr
      end

      io << '\n'
    end
  end

  class Node
    alias Trie = Hash(String, Node)

    property item : Item?
    getter trie : Trie

    def initialize(@item = nil, @trie = Trie.new)
    end

    def find!(key : String) : Node
      node = self
      key.each_char { |c| node = node.trie[c] ||= Node.new }
      node
    end

    def find(key : String) : Node?
      node = self
      key.each_char { |c| return unless node = node.trie[c]? }
      node
    end

    def scan(chars : Array(String), caret : Int32 = 0) : Nil
      node = self

      caret.upto(chars.size - 1) do |i|
        char = chars.unsafe_fecth(i)
        break unless node = node.trie[char]?
        node.item.try { |x| yield x }
      end
    end

    def each : Nil
      queue = [self]

      while node = queue.pop?
        node.trie.each_value do |node|
          queue << node
          node.item.try { |x| yield x }
        end
      end
    end
  end

  getter file : String # default read/save file
  getter size = 0      # dict size by unique keys

  getter dlock = 1 # default permission lock
  getter mtime = 0 # dict's modification time

  getter index = Node.new   # fast trie lookup
  getter items = [] of Item # all items loaded from files or memory

  def initialize(@file : String, @dlock : Int32 = 1)
  end

  def load!(file = @file) : Nil
    label = File.basename(file)
    lines = 0

    elapse = Time.measure do
      File.each_line(file) do |line|
        line = line.strip
        next if line.blank?

        upsert(Item.parse(line, @dlock))
        lines += 1
      rescue err
        puts "[ERROR parsing <#{lines}> `#{label}`>: #{err}]".colorize.red
      end
    end

    elapse = elapse.total_milliseconds.round.to_i
    puts "[DICT <#{label}> loaded: #{lines} lines, elapse: #{elapse}ms]".colorize.green

    # set mtime from file stats
    @mtime = Item.mtime(File.info(file).modification_time) if @mtime == 0
  end

  def save!(file = @file) : Nil
    label = File.basename(file)

    File.open(file, "a") do |io|
      @items.each do |item|
        item.println(io, @dlock)
      end
    end

    puts "[DICT <#{label}> saved: #{items.size} entries]".colorize.yellow
  end

  def upsert(new_item : Item) : Nil
    @items << new_item
    @mtime = new_item.mtime if @mtime < new_item.mtime

    unless item = @index.find!(key).item
      item = Item.new(new_item.key, [""])
      item.plock = @dlock
      @size += 1
    end

    item.merge!(new_item)
  end

  def upsert!(new_item : Item) : Nil
    upsert(item)
    File.open(@file, "a") { |io| item.println(io, @dlock) }
  end

  def find(key : String) : Item?
    @index.find(key).try(&.item)
  end

  delegate scan, to: @index
  delegate each, to: @index
end
