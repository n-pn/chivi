require "./vp_term"

class CV::VpTrie
  alias Trie = Hash(Char, VpTrie)

  property base : VpTerm? = nil
  getter privs = {} of String => VpTerm
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
      break unless term = node.base
      yield term
    end
  end

  def scan(chars : Array(Char), uname : String = "", idx : Int32 = 0) : Nil
    node = self

    idx.upto(chars.size - 1) do |i|
      char = chars.unsafe_fetch(i)
      break unless node = node._next[char]?
      break unless term = node.privs[uname]? || node.base
      yield term
    end
  end

  def push!(term : VpTerm) : VpTerm?
    # term is a user private entry if uname is prefixed with a "!"
    if term.is_priv
      uname = term.uname
      return unless newer?(term, @privs[uname]?)
      @privs[uname] = term
    else
      return unless newer?(term, @base)
      @base = term
    end
  end

  # checking if new term can overwrite current term
  private def newer?(term : VpTerm, prev : VpTerm)
    # do not record if term is outdated
    return if term.mtime < prev.mtime

    if is_redo_action?(term, prev)
      prev._flag = 2_u8
      term._prev = prev._prev
    else
      prev._flag = 1_u8
      term._prev = prev
    end

    term
  end

  # :ditto:
  def newer?(term : VpTerm, prev : Nil)
    term
  end

  # skipping previous entry if edit under 5 minutes
  @[AlwaysInline]
  def is_redo_action?(term : VpTerm, prev : VpTerm)
    return false unless term.uname == prev.uname
    prev.mtime - prev.mtime <= 5
  end
end
