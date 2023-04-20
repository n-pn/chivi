require "./ent_term"
require "./ner_node"

class MT::NerDict
  class Trie
    property data : EntTerm? = nil
    getter trie = {} of Char => Trie

    def [](key : String)
      key.each_char.reduce(self) { |acc, chr| acc.trie[chr] ||= Trie.new }
    end

    def []=(key : String, data : EntTerm?)
      self[key].data = data
    end
  end

  #####

  @trie = Trie.new

  def load_tsv!(path : String)
    File.each_line(path) do |line|
      next if line.empty?

      zstr, trans, marks = line.split('\t')
      @trie[zstr] = EntTerm.new(marks.split(' '), trans)
    end

    self
  end

  def fetch_all(chars : Enumerable(Char), start = 0, &)
    node = @trie

    start.upto(chars.size &- 1) do |index|
      char = chars.unsafe_fetch(index)

      break unless node = node.trie[char]?
      next unless term = node.data

      yield NerNode.new(term, len: index &- start &+ 1, temp: false)
    end
  end

  ###

  DIR = "var/mtdic/fixed/zners"

  class_getter base : self { new.load_tsv!("#{DIR}/base.tsv") }
end
