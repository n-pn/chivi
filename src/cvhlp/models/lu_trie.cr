class TL::LuTrie
  alias Next = Hash(Char, LuTrie)

  property data : Int32? = nil
  property trie : Next? = nil

  def next(char : Char) : self
    trie = @trie ||= Next.new
    trie[char] ||= LuTrie.new
  end

  def set(word : String, data : Int32) : Nil
    node = self

    word.each_char do |char|
      trie = node.trie ||= Next.new
      node = trie[char] ||= LuTrie.new
    end

    node.data = data
  end

  def all(input : String)
    node = self
    input.each_char do |char|
      return unless node = node.trie.try(&.[char]?)
      node.data.try { |x| yield x }
    end
  end

  def all(chars : Array(Char), start = 0)
    node = self

    chars[start..].each do |char|
      return unless node = node.trie.try(&.[char]?)
      node.data.try { |x| yield x }
    end
  end
end
