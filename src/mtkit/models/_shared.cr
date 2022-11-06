class VP::ZhTrie(T)
  property data : T? = nil
  property trie : Hash(Char, T)? = nil

  def next(char : Char) : self
    trie = @trie ||= Hash(Char, T).new
    trie[char] ||= ZhTrie.new
  end

  def next?(char : Char) : self | Nil
    @trie.try(&.[char]?)
  end
end
