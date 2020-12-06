require "./vp_term"

class Chivi::VpTrie
  alias Trie = Hash(String, VpTrie)

  property item : VpTerm?
  getter trie : Trie

  def initialize(@item = nil, @trie = Trie.new)
  end

  def find!(key : String) : VpTrie
    node = self
    key.each_char { |c| node = node.trie[c] ||= VpTrie.new }
    node
  end

  def find(key : String) : VpTrie?
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
