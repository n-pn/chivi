require "./mt_term"

class MT::TrieDict
  property term : MtTerm? = nil
  property hash = {} of Char => TrieDict

  def [](zstr : String)
    zstr.each_char.reduce(self) { |acc, char| acc.hash[char] ||= TrieDict.new }
  end

  def []=(zstr : String, term : MtTerm?)
    self[zstr].term = term
  end

  def match(chars : Array(Char), start : Int32 = 0, dpos : Int32 = 2)
    node = self
    size = 0

    best_term = nil
    best_size = 0

    start.upto(chars.size &- 1) do |idx|
      char = chars.unsafe_fetch(idx)
      char = CharUtil.to_canon(char, true)

      break unless node = node.hash[char]?
      size &+= 1

      next unless term = node.term
      best_term, best_size = term, size
    end

    {best_term, best_size, dpos} if best_term
  end
end
