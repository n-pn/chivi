require "../mt_core/mt_defn"
require "./qt_node"

class MT::QtDict
  @data = [] of Trie

  def initialize
  end

  # def load_tsv!(path : String) : self
  #   trie = Trie.new

  #   File.each_line(path) do |line|
  #     next if line.empty?
  #     zstr, defs = line.split('\t', 2)

  #     node = defs.empty? ? nil : make_node(zstr, defs, 'ǀ')
  #     trie[zstr] = node
  #   end

  #   @data << trie
  #   self
  # end

  # load terms from dic file
  def load_dic!(dname : String) : self
    trie = Trie.new

    db_path = MtDefn.db_path(dname)

    DB.open("sqlite3:#{db_path}") do |db|
      db.query_each "select zstr, vstr, _fmt from defns where vstr <> ''" do |rs|
        zstr = rs.read(String)
        vstr = rs.read(String).split('\t').first
        fmt = FmtFlag.new(rs.read(Int32).to_u16)
        trie[zstr] = QtNode.new(zstr: zstr, vstr: vstr, dic: 2, idx: 0, fmt: fmt)
      end
    end

    @data << trie
    self
  end

  @[AlwaysInline]
  def make_node(zstr : String, defs : String, dic = 0, sep = '\t') : QtNode
    QtNode.new(zstr: zstr, vstr: defs.split(sep).first, dic: dic, idx: 0)
  end

  def find_best(chars : Array(Char), start = 0) : QtNode
    output = nil

    @data.reverse_each do |trie|
      node = trie

      start.upto(chars.size &- 1) do |idx|
        char = chars.unsafe_fetch(idx)
        break unless node = node.trie[char]?

        next unless data = node.data
        output = data.dup!(idx) unless output && output.zlen >= data.zlen
      end
    end

    output || begin
      char = chars.unsafe_fetch(start)
      QtNode.new(char, idx: start)
    end
  end

  class Trie
    property data : QtNode? = nil
    getter trie = {} of Char => Trie

    def []=(zstr : String, data : QtNode?)
      node = self

      zstr.each_char do |char|
        node = node.trie[char] ||= Trie.new
      end

      node.data = data
    end

    def find!(zstr : String)
      node = self

      zstr.each_char do |char|
        trie = node.trie ||= Hash(Char, Trie).new
        node = trie[char] ||= Trie.new
      end

      node
    end

    # def find(zstr : String)
    #   node = self

    #   zstr.each_char do |char|
    #     return unless trie = node.trie
    #     return unless node = trie[char]?
    #   end

    #   node
    # end
  end
end
