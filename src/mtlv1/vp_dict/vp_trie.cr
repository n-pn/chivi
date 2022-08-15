require "./vp_term"

class V1::VpLeaf
  property base : CV::VpTerm? = nil
  property temp : CV::VpTerm? = nil

  getter privs = {} of String => CV::VpTerm

  def add(term : CV::VpTerm) : CV::VpTerm?
    # term is a user private entry if uname is prefixed with a "!"
    case term
    when .priv?
      uname = term.uname
      @privs[uname] = term if newer?(term, @privs[uname]?)
    when .temp?
      @temp = term if newer?(term, @temp)
    else
      @temp = term if newer?(term, @temp)
      @base = term if newer?(term, @base)
    end
  end
end

class CV::VpTrie
  alias Trie = Hash(Char, VpTrie)

  getter _next = Trie.new
  property base : VpTerm? = nil
  property temp : VpTerm? = nil

  getter privs = {} of String => VpTerm

  def each
    queue = [self]

    while node = queue.shift?
      yield node if node.base || !node.privs.empty?
      node._next.each_value { |x| queue << x }
    end
  end

  def find!(input : String) : VpTrie
    node = self
    input.each_char { |c| node = node._next[c] ||= VpTrie.new }
    node
  end

  def find(input : String) : VpTrie?
    node = self
    input.each_char { |c| return unless node = node._next[c]? }
    node
  end

  def find(chars : Array(Char)) : VpTrie?
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

  def scan_best(chars : Array(Char), idx : Int32 = 0, user : String = "", temp : Bool = false) : Nil
    node = self

    idx.upto(chars.size - 1) do |i|
      char = chars.unsafe_fetch(i)
      break unless node = node._next[char]?

      node.base.try { |term| yield term unless term.empty? }
      node.temp.try { |term| yield term unless term.empty? } if temp
      node.privs[user]?.try { |term| yield term unless term.empty? }
    end
  end

  def push!(term : VpTerm) : VpTerm?
    # term is a user private entry if uname is prefixed with a "!"
    case term
    when .priv?
      @privs[term.uname] = term if term.newer?(@privs[term.uname]?)
    when .temp?
      @privs[term.uname] = term if term.newer?(@privs[term.uname]?)
      @temp = term if term.newer?(@temp)
    else
      @privs[term.uname] = term if term.newer?(@privs[term.uname]?)
      @temp = term if term.newer?(@temp)
      @base = term if term.newer?(@base)
    end
  end
end
