require "../data/sp_term"
require "./mt_node"

class SP::MtDict
  class_getter sino_vi : self do
    new
      # .load!("essence")
      .load!("sino_vi")
  end

  class_getter pin_yin : self do
    new
      # .load!("essence")
      .load!("pin_yin")
  end

  def initialize
    @trie = Trie.new
  end

  LOAD_SQL = "select zstr, defs from #{SpTerm.table}"

  def load!(dname : String) : self
    SpTerm.open_db(dname) do |db|
      db.query_each(LOAD_SQL) do |rs|
        set!(rs.read(String), rs.read(String))
      end
    end

    self
  end

  def set!(zstr : String, defs : String)
    node = @trie.find!(zstr)

    if defs.empty?
      node.data = nil
    else
      val = defs.split('\t').first
      node.data = MtNode.new(val: val, size: zstr.size)
    end
  end

  def find(zstr : String)
    @trie.find(zstr).try(&.data)
  end

  def scan(zstr : String, start = 0, &)
    scan(zstr.chars, start: start) { |data| yield data }
  end

  def scan(chars : Array(Char), start = 0, &)
    node = @trie

    start.upto(chars.size - 1) do |index|
      return unless trie = node.trie
      return unless node = trie[chars.unsafe_fetch(index)]?

      next unless data = node.data
      yield data
    end
  end

  class Trie
    property data : MtNode? = nil
    property trie : Hash(Char, Trie)? = nil

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
