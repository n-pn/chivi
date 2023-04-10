require "./v0_term"
require "../core/v0_node"

class MT::V0Dict
  class_getter sino_vi : self do
    new
      # .load_dic!("essence")
      .load_dic!("sino_vi")
  end

  class_getter pin_yin : self do
    new
      # .load_dic!("essence")
      .load_dic!("pin_yin")
  end

  class_getter hv_name : self do
    new
      # .load_dic!("essence")
      .load_dic!("hv_name")
  end

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

    V0Term.load_data(dname) do |zstr, defs|
      node = defs.empty? ? nil : make_node(zstr, defs)
      trie[zstr] = node
    end

    @data << trie
    self
  end

  @[AlwaysInline]
  def make_node(zstr : String, defs : String, sep = '\t') : V0Node
    V0Node.new(val: defs.split(sep).first, len: zstr.size, idx: 0)
  end

  def find_best(inp : Array(Char), start = 0) : V0Node?
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
    property data : V0Node? = nil
    property trie = {} of Char => Trie

    def [](key : String)
      key.each_char.reduce(self) { |acc, chr| acc.trie[chr] ||= Trie.new }
    end

    def []=(key : String, data : V0Node?)
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
