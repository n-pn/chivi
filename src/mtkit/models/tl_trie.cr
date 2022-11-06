class TL::TlTrie
  alias Trie = Hash(Char, TlTrie)

  property data : Int32? = nil
  property trie : Trie? = nil

  def next(char : Char) : self
    trie = @trie ||= Trie.new
    trie[char] ||= TlTrie.new
  end

  def set(word : String, data : Int32) : Nil
    node = self

    word.each_char do |char|
      trie = node.trie ||= Trie.new
      node = trie[char] ||= TlTrie.new
    end

    node.data = data
  end

  def all(word : String)
    node = self
    word.each_char do |char|
      return unless node = node.trie.try(&.[char]?)
      node.data.try { |x| yield x }
    end
  end

  def all(word : Array(Char))
    node = self
    word.each do |char|
      return unless node = node.trie.try(&.[char]?)
      node.data.try { |x| yield x }
    end
  end
end
