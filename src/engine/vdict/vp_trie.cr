require "./vterm"

class CV::VpTrie
  alias Trie = Hash(Char, VpTrie)

  property term : Vterm? = nil
  getter edits = [] of Vterm
  getter _next = Trie.new

  def find!(key : String) : VpTrie
    node = self
    key.each_char { |c| node = node._next[c] ||= VpTrie.new }
    node
  end

  def find(key : String) : VpTrie?
    node = self
    key.each_char { |c| return unless node = node._next[c]? }
    node
  end

  def scan(chars : Array(Char), idx : Int32 = 0) : Nil
    node = self

    idx.upto(chars.size - 1) do |i|
      char = chars.unsafe_fetch(i)
      break unless node = node._next[char]?
      node.term.try { |x| yield x }
    end
  end

  def each : Nil
    queue = [self]

    while last = queue.pop?
      last._next.each_value do |node|
        queue << node
        yield node unless node.edits.empty?
      end
    end
  end

  def to_a : Array(Vterm)
    res = [] of Vterm
    each { |term| res << term }
    res
  end
end
