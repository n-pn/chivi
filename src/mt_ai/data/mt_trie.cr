require "./vi_dict"
require "./mt_term"

class MT::MtTrie
  class_getter pin_yin : self { new("pin_yin").load_db3!.load_tsv! }
  class_getter hv_word : self { new("hv_word").load_db3!.load_tsv! }
  class_getter hv_name : self { new("hv_name").load_db3!.load_tsv! }
  class_getter essence : self { new("essence").load_db3!.load_tsv! }

  ###

  getter root = Node.new

  def initialize(@dname : String)
  end

  @[AlwaysInline]
  def add(zstr : String, vstr : String, attr : MtAttr)
    @root[zstr] = MtTerm.new(vstr: vstr, attr: attr)
  end

  def find_best(chars : Array(Char), start = 0, dpos = 2)
    node = @root
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

  ###

  def load_tsv!(dname : String = @dname)
    tsv_path = ViTerm.db_path(dname, "tsv")
    return self unless File.file?(tsv_path)

    File.each_line(tsv_path) do |line|
      cols = line.split('\t')
      next if cols.size < 3
      add(cols[0], cols[2], MtAttr.parse_list(cols[3]?))
    end

    self
  end

  def load_db3!(dname : String = @dname)
    ViTerm.db(dname).open_ro do |db|
      db.query_each("select zstr, vstr, iattr from terms") do |rs|
        zstr, vstr, iattr = rs.read(String, String, Int32)
        add(zstr, vstr, MtAttr.new(iattr))
      end
    end

    self
  end

  class Node
    property term : MtTerm? = nil
    property hash = {} of Char => Node

    def [](zstr : String)
      zstr.each_char.reduce(self) { |acc, char| acc.hash[char] ||= Node.new }
    end

    def []=(zstr : String, term : MtTerm?)
      self[zstr].term = term
    end
  end
end
