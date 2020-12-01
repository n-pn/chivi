class Chivi::TrieDict
  SEP_K = "\t"
  SEP_V = "¦"

  struct Item
    getter key : String
    getter val : String
    getter alt : String

    def initialize(@key : String, @val : String, @alt = "")
    end

    def inspect(io : IO) : Nil
      io << '⟨' << @key << '|' << @val << '|' << @alt << '⟩'
    end

    def to_s(io : IO) : Nil
      {@key, @val, @alt}.join(io, SEP_K)
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
      str.split(SEP_V)
    end
  end

  class Node
    property item : Item? = nil
    getter succ : Hash(Char, Node) { Hash(Char, Node).new }

    def travel(key : String)
      node = self
      key.each_char { |c| node = node.succ[c] ||= Node.new }
      node
    end

    def search(key : String)
      node = self
      key.each_char { |char| return unless node = node.succ[char]? }
      node
    end

    def each : Nil
      queue = [self]

      while node = queue.pop?
        node.succ.each_value do |node|
          queue << node

          next unless item = node.item
          yield item
        end
      end
    end

    def list(limit : Int32 = 50, offset : Int32 = 0) : Array(Item)
      ary = [] of Item

      each do |item|
        next unless yield item

        if offset > 0
          offset -= 1
        else
          ary << item
          break if ary.size == limit
        end
      end

      ary
    end
  end

  getter root = Node.new
  getter size = 0

  def set(key : String) : Tuple(Item?, Item?)
    node = @root.travel(key)

    @size -= 1 if old_item = node.item
    yield node
    @size += 1 if new_item = node.item

    {new_item, old_item}
  end

  def put(key : String, val : String, alt = "") : Tuple(Item?, Item?)
    set(key, &.item = Item.new(key, val, alt))
  end

  def delete(key : String) : Tuple(Item?, Item?)
    set(key) do |node|
      if item = node.item
        alt = {item.val, item.alt}.join(SEP_V)
      end

      node.item = Item.new(key, "", alt || "")
    end
  end

  def remove(key : String) : Tuple(Item?, Item?)
    set(key, &.item = nil)
  end

  def get(key : String) : Item?
    @root.search(key).try(&.item)
  end

  def []?(key : String) : Item?
    get(key)
  end

  def has_key?(key : String) : Bool
    return false unless node = get(key)
    !node.empty?
  end

  include Enumerable(Item)
  delegate each, to: @root
  delegate list, to: @root

  def list(limit = 50, offset = 0, skip_empty = false)
    @root.list(limit, offset) { |item| !(skip_empty && item.empty?) }
  end

  def scan(chars : Array(Char), from = 0) : Void
    node = @root

    from.upto(chars.size - 1) do |idx|
      char = chars.unsafe_fetch(idx)
      return unless node = node.succ[char]?

      next unless item = node.item
      yield item unless item.empty?
    end
  end
end
