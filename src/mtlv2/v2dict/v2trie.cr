require "./v2term"

class MtlV2::V2Trie
  alias Trie = Hash(Char, V2Trie)

  property base : V2Term? = nil
  getter privs = {} of String => V2Term
  getter _next = Trie.new

  def each
    queue = [self]

    while node = queue.shift?
      yield node if node.base || !node.privs.empty?
      node._next.each_value { |x| queue << x }
    end
  end

  def find!(input : String) : V2Trie
    node = self
    input.each_char { |c| node = node._next[c] ||= V2Trie.new }
    node
  end

  def find(input : String) : V2Trie?
    node = self
    input.each_char { |c| return unless node = node._next[c]? }
    node
  end

  def find(chars : Array(Char)) : V2Trie?
    node = self
    chars.each { |c| return unless node = node._next[c]? }
    node
  end

  def scan(chars : Array(Char), idx : Int32 = 0) : Nil
    node = self

    idx.upto(chars.size - 1) do |i|
      char = chars.unsafe_fetch(i)
      break unless node = node._next[char]?

      node.base.try { |term| yield term unless term.empty? }
    end
  end

  def scan(chars : Array(Char), uname : String = "", idx : Int32 = 0) : Nil
    node = self

    idx.upto(chars.size - 1) do |i|
      char = chars.unsafe_fetch(i)
      break unless node = node._next[char]?

      node.base.try { |term| yield term unless term.empty? }
      node.privs[uname]?.try { |term| yield term unless term.empty? }
    end
  end

  def push!(term : V2Term) : V2Term?
    # term is a user private entry if uname is prefixed with a "!"
    if term.is_priv
      uname = term.uname
      @privs[uname] = term if newer?(term, @privs[uname]?)
    else
      @base = term if newer?(term, @base)
    end
  end

  # checking if new term can overwrite current term
  def newer?(term : V2Term, prev : V2Term?) : Bool
    return true unless prev
    time_diff = term.mtime - prev.mtime

    # do not record if term is outdated
    return false if time_diff < 0

    if term.uname == prev.uname && time_diff <= 5
      prev._flag = 2_u8
      term._prev = prev._prev
    else
      prev._flag = 1_u8
      term._prev = prev
    end

    true
  end
end
