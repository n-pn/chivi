class Chivi::EditDict
  class Item
    getter key : String
    getter val : String
    getter alt : String

    getter uname : String
    getter power : Int32
    getter mtime : Int32

    property state : Int32

    def initialize(@key, @val, @alt, @uname, @power, @mtime = 0, @state = 0)
    end

    def inspect(io : IO) : Nil
      io << '⟨'
      {@key, @val, @alt, @uname, @power, @mtime, @state}.join('|')
      io << '⟩'
    end

    def to_s(io : IO) : Nil
      {@key, @val, @alt, @uname, @power, @mtime}.join(io, "\t")
    end

    def to_s : String
      String.build { |io| to_s(io) }
    end

    delegate empty?, to: @val
    getter vals : Array(String) { split(@val) }

    def alts : Array(String)
      split(@alt)
    end

    private def split(str : String)
      str.split("¦")
    end

    def power_than?(other : self) : Bool
      return @mtime >= other.mtime if @power == @other.power
      @power > other.power
    end

    def fix_states!(ontop : self) : Nil
      if @mtime < ontop.mtime
        @state = 2
      elsif self != ontop
        @state = 1
      end
    end

    EPOCH = Time.utc(2020, 1, 1)

    # time in utc
    def utime
      EPOUCH + @mtime.minutes
    end

    def self.mtime(utime = Time.utc)
      (utime - EPOCH).total_minutes.to_i
    end
  end

  class Node
    getter items = [] of Item
    getter ontop : Item? = nil

    def add(item : Item) : Item?
      @items << item
      return if @ontop && @ontop.power_than?(item)

      @item.each(&.fix_states!(item))
      @ontop = item
    end

    def sort!
      @items.sort_by!(&.mtime)
    end
  end

  getter data = {} of String => Node
  getter min_power : Int32 = 1

  def initialize(@min_power)
  end

  def put(key : String, val : String, alt : String, user : String)
    node = @data[item.key] ||= Node.new
    node.add(item)
  end

  include Enumerable(Item)

  def each
    @data.each_value do |node|
      node.each { |item| yield item }
    end
  end

  def list_top
    @data.each_value do |node| 
      yield 
    end

  end
end
