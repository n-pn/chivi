require "./ent_mark"

class MT::NerDict
  class Trie
    getter bner = EntMark::None # mark begin
    getter iner = EntMark::None # mark intermediate
    getter ener = EntMark::None # mark end
    getter sner = EntMark::None # mark single

    getter defs = {} of EntMark => String # translation if avaiable
    getter trie = {} of Char => Trie
  end

  def [](key : String)
    key.each_char.reduce(self) { |acc, chr| acc.trie[chr] ||= Trie.new }
  end

  # def []=(key : String, data : NerNode?)
  #   self[key].data = data
  # end
end
