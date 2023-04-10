require "./qt_term"
require "./qt_node"

class MT::QtDict
  @data = [] of Trie

  def initialize
  end

  def load_tsv!(path : String) : self
    trie = Trie.new

    File.each_line(path) do |line|
      next if line.empty?
      zstr, defs = line.split('\t', 2)

      node = defs.empty? ? nil : make_node(zstr, defs, 'ǀ')
      trie[zstr] = node
    end

    @data << trie
    self
  end

  # load terms from dic file
  def load_dic!(dname : String) : self
    trie = Trie.new

    QtTerm.load_data(dname) do |zstr, defs|
      node = defs.empty? ? nil : make_node(zstr, defs)
      trie[zstr] = node
    end

    @data << trie
    self
  end

  @[AlwaysInline]
  def make_node(zstr : String, defs : String, sep = '\t') : QtNode
    QtNode.new(val: defs.split(sep).first, len: zstr.size, idx: 0)
  end

  def find_best(inp : Array(Char), start = 0) : QtNode?
    output = nil

    @data.reverse_each do |trie|
      node = trie

      start.upto(inp.size &- 1) do |idx|
        char = inp.unsafe_fetch(idx)
        break unless node = node.trie[char]?

        next unless data = node.data
        output = data.dup!(idx) unless output && output.len >= data.len
      end
    end

    output
  end

  class Trie
    property data : QtNode? = nil
    property trie = {} of Char => Trie

    def [](key : String)
      key.each_char.reduce(self) { |acc, chr| acc.trie[chr] ||= Trie.new }
    end

    def []=(key : String, data : QtNode?)
      self[key].data = data
    end

    def find!(zstr : String)
      node = self

      zstr.each_char do |char|
        trie = node.trie ||= Hash(Char, Trie).new
        node = trie[char] ||= Trie.new
      end

      node
    end

    def find(zstr : String)
      node = self

      zstr.each_char do |char|
        return unless trie = node.trie
        return unless node = trie[char]?
      end

      node
    end
  end
end
