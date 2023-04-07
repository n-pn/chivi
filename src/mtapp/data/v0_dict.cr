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

  def initialize
    @ent = Trie.new
    @all = [@ent]
  end

  def run_ner!(key_chars : Array(Char), val_char = key_chars)
    # TODO: fill dictionary with ner result
  end

  # remover all cached entities
  def clear_entities!
    @ent.trie.clear
  end

  def load_tsv!(dname : String) : self
    # TODO: allow to load v0 dict from tsv files
    self
  end

  # load terms from dic file
  def load_dic!(dname : String) : self
    trie = Trie.new

    V0Term.load_data(dname) do |zstr, defs|
      trie[zstr] = make_node(zstr, defs)
    end

    @all << trie
    self
  end

  @[AlwaysInline]
  def make_node(zstr : String, defs : String) : V0Node?
    return if defs.empty?
    V0Node.new(val: defs.split('\t').first, len: zstr.size, idx: 0)
  end

  def find_best(inp : Array(Char), start = 0) : V0Node?
    @all.reverse_each do |trie|
      node = trie

      start.upto(inp.size &- 1) do |idx|
        char = inp.unsafe_fetch(idx)
        break unless node = node.trie[char]?
        node.data.try { |data| return data.dup!(idx) }
      end
    end
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
