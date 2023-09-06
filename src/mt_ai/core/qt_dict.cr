require "../data/*"

class MT::QtDict
  ###

  @data = Trie.new

  def initialize(@dname : String)
  end

  def load_tsv!(dname : String = @dname)
    tsv_path = DbTerm.db_path(dname, "tsv")
    return self unless File.file?(tsv_path)

    File.each_line(tsv_path) do |line|
      cols = line.split('\t')
      next if cols.size < 3
      add(cols[0], cols[2], MtProp.parse_list(cols[3]?))
    end

    self
  end

  def load_db3!(dname : String = @dname)
    DbTerm.db(dname).open_ro do |db|
      db.query_each("select zstr, vstr, iprop from terms") do |rs|
        zstr, vstr, iprop = rs.read(String, String, Int32)
        add(zstr, vstr, MtProp.new(iprop))
      end
    end

    self
  end

  @[AlwaysInline]
  def add(zstr : String, vstr : String, prop : MtProp)
    @data[zstr] = MtTerm.new(vstr, prop)
  end

  ###

  def find(chars : Array(Char), start = 0) : {MtTerm, Int32, Int32}
    best_term, best_size = init(chars, start)
    best_d_id = 0

    node = @data
    size = 0

    start.upto(chars.size &- 1) do |idx|
      char = chars.unsafe_fetch(idx)
      char = CharUtil.to_canon(char, true)

      break unless node = node.trie[char]?

      size += 1
      next if size < best_size
      next unless term = node.data

      best_term = term
      best_size = size
      best_d_id = 2
    end

    {best_term, best_size, best_d_id}
  end

  def init(chars : Array(Char), start = 0)
    first_char = chars.unsafe_fetch(start)

    unless CharUtil.fw_alnum?(first_char)
      return {MtTerm.from_char(first_char), 1}
    end

    vstr = String::Builder.new
    vstr << CharUtil.normalize(first_char)
    prop = MtProp::None

    index = start &+ 1

    while index < chars.size
      char = chars.unsafe_fetch(index)
      break unless '！' <= char <= '～'

      vstr << CharUtil.normalize(char)
      prop = MtProp::Asis unless CharUtil.fw_alnum?(char)

      index &+= 1
    end

    {MtTerm.new(vstr.to_s, prop), index &- start}
  end

  class Trie
    property data : MtTerm? = nil
    property trie = {} of Char => Trie

    def [](zstr : String)
      zstr.each_char.reduce(self) { |acc, char| acc.trie[char] ||= Trie.new }
    end

    def []=(zstr : String, data : MtTerm?)
      self[zstr].data = data
    end
  end

  ###

  class_getter pin_yin : self { new("core/pin_yin").load_db3!.load_tsv!("core/grammar") }
  class_getter hv_word : self { new("core/hv_word").load_db3!.load_tsv!("core/grammar") }
  class_getter hv_name : self { new("core/hv_name").load_db3!.load_tsv!("core/grammar").load_tsv! }
end
