require "./vp_term"

class CV::VpTrie
  alias Trie = Hash(Char, VpTrie)

  property term : VpTerm? = nil
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
    queue = Deque(VpTrie){self}

    while first = queue.shift?
      yield first if first.term
      first._next.each_value { |node| queue << node }
    end
  end

  def to_a : Array(VpTerm)
    res = [] of VpTerm
    each { |term| res << term }
    res
  end

  def push(term : VpTerm) : VpTerm
    @term = term
  end
end
