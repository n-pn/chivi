require "./dict_item"

class Libcv::DictTrie
  property item : DictItem? = nil

  alias Trie = Hash(Char, DictTrie)
  getter trie : Trie { Trie.new }

  def initialize
  end

  def initialize(@item : DictItem)
  end

  def remove!
    @item = nil
  end

  def removed?
    @item.nil?
  end

  include Enumerable(DictItem)

  def each
    queue = [self]

    while node = queue.pop?
      node.trie.each_value do |node|
        queue << node
        yield node.item if node.item
      end
    end
  end

  def dig!(key : Array(Char), from = 0) : DictTrie
    node = self

    from.upto(key.size - 1) do |idx|
      char = key.unsafe_fetch(idx)
      node = node.trie[char] ||= DictTrie.new
    end

    node
  end

  def dig(key : Array(Char), from = 0) : DictTrie?
    node = self

    from.upto(key.size - 1) do |idx|
      char = key.unsafe_fetch(idx)
      return unless node = node.trie[char]?
    end

    node
  end

  def includes?(key : String) : Bool
    return false unless node = dig(key.chars)
    !node.empty?
  end

  def scan(chars : Array(Char), from = 0) : Void
    node = self

    from.upto(chars.size - 1) do |idx|
      char = chars.unsafe_fetch(idx)
      return unless node = node.trie[char]?

      if item = node.item
        yield item
      end
    end
  end

  def scan(input : String, from = 0) : Void
    scan(input.chars, from) { |node| yield node }
  end
end
