require "./mt_term"

class MT::MtTrie
  alias Map = Hash(Char, MtTrie)

  property data : MtTerm? = nil
  property trie : Map? = nil

  def each
    queue = [self]

    while node = queue.shift?
      yield node if node.data
      node.trie.each_value { |x| queue << x }
    end
  end

  def push!(term : MtTerm) : Nil
    node = find!(term.key)
    node.data = term.val.empty? ? nil : term
  end

  def find!(input : String) : MtTrie
    node = self

    input.each_char do |char|
      trie = node.trie ||= Map.new
      node = trie[char] ||= MtTrie.new
    end

    node
  end

  def find(input : String) : MtTrie?
    find(input.chars)
  end

  def find(chars : Array(Char)) : MtTrie?
    node = self

    chars.each do |char|
      return unless trie = node.trie
      return unless node = trie[char]?
    end

    node
  end

  def scan(chars : Array(Char), start : Int32 = 0) : Nil
    node = self

    (start...chars.size).each do |i|
      char = chars.unsafe_fetch(i)

      break unless trie = node.trie
      break unless node = trie[char]?

      if data = node.data
        yield data
      end
    end
  end
end
