require "./vp_term"

class CV::VpTrie
  alias Trie = Hash(Char, VpTrie)

  property term : VpTerm? = nil
  getter edits = [] of VpTerm
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

  def each(full : Bool = true) : Nil
    queue = [self]

    while last = queue.pop?
      last._next.each_value do |node|
        if full
          node.edits.each { |term| yield term }
        elsif term = node.term
          yield term
        end

        queue << node
      end
    end
  end

  def to_a : Array(VpTerm)
    res = [] of VpTerm
    each { |term| res << term }
    res
  end
end
