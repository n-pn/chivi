require "./vp_term"

# class V1::VpLeaf
#   property base : CV::VpTerm? = nil
#   property temp : CV::VpTerm? = nil

#   getter privs = {} of String => CV::VpTerm

#   def add(term : CV::VpTerm) : CV::VpTerm?
#     # term is a user private entry if uname is prefixed with a "!"
#     case term
#     when .priv?
#       uname = term.uname
#       @privs[uname] = term if newer?(term, @privs[uname]?)
#     when .temp?
#       @temp = term if newer?(term, @temp)
#     else
#       @temp = term if newer?(term, @temp)
#       @base = term if newer?(term, @base)
#     end
#   end
# end

class CV::VpTrie
  alias Trie = Hash(Char, VpTrie)

  property term : VpTerm? = nil
  property trie : Trie? = nil

  def each
    queue = [self]

    while node = queue.shift?
      yield node if node.term

      node.trie.try do |trie|
        trie.each_value { |x| queue << x }
      end
    end
  end

  def find!(input : String) : VpTrie
    node = self

    input.each_char do |char|
      trie = node.trie ||= Trie.new
      node = trie[char] ||= VpTrie.new
    end

    node
  end

  def find(input : String) : VpTrie?
    node = self

    input.each_char do |char|
      return unless trie = node.trie
      return unless node = trie[char]?
    end

    node
  end

  def find(chars : Array(Char)) : VpTrie?
    node = self

    input.each do |char|
      return unless trie = node.trie
      return unless node = trie[char]?
    end

    node
  end

  def scan(chars : Array(Char), idx : Int32 = 0) : Nil
    node = self

    idx.upto(chars.size - 1) do |i|
      break unless trie = node.trie

      char = chars.unsafe_fetch(i)
      break unless node = trie[char]?

      node.term.try { |term| yield term }
    end
  end
end
