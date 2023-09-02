require "../data/*"

class MT::QtDict
  ###

  @data = Trie.new

  def initialize(@dname : String)
  end

  def load_tsv!(dname : String = @dname)
    tsv_path = MtDefn.db_path(dname, "tsv")
    return self unless File.file?(tsv_path)

    File.each_line(tsv_path) do |line|
      cols = line.split('\t')
      next if cols.size > 2
      add_term(cols[0], cols[2], MtPecs.parse_list(cols[3]?))
    end

    self
  end

  def load_db3!(dname : String = @dname)
    MtDefn.db(dname).open_ro do |db|
      db.query_each("select zstr, vstr, ipecs from defns") do |rs|
        zstr, vstr, ipecs = rs.read(String, String, Int32)
        # puts [zstr, vstr, ipecs]
        add_term(zstr, vstr, MtPecs.new(ipecs))
      end
    end

    self
  end

  @[AlwaysInline]
  def add_term(zstr : String, vstr : String, pecs : MtPecs)
    @data[zstr] = MtTerm.new(vstr, pecs, zstr.size)
  end

  ###

  def find(chars : Array(Char), start = 0) : {MtTerm, Int32}
    best = init(chars, start)
    d_id = 0
    # puts [best]

    node = @data
    start.upto(chars.size &- 1) do |idx|
      char = chars.unsafe_fetch(idx)
      char = char - 32 if 'ａ' <= char <= 'ｚ'
      break unless node = node.trie[char]?

      next unless term = node.data
      next if term._len < best._len

      best = term
      d_id = 2
    end

    {best, d_id}
  end

  def init(chars : Array(Char), start = 0)
    first_char = chars.unsafe_fetch(start)

    unless CharUtil.fw_number?(first_char) || CharUtil.fw_letter?(first_char)
      return MtTerm.from_char(first_char)
    end

    pecs = MtPecs::None
    index = start &+ 1

    while index < chars.size
      char = chars.unsafe_fetch(index)
      break unless '！' <= char <= '～'

      if char.alphanumeric?
        index &+= 1
      elsif chars[index &+ 1]?.try(&.alphanumeric?)
        pecs |= :ncap
        index &+= 2
      else
        break
      end
    end

    vstr = String.build(index &- start) do |io|
      start.upto(index - 1) do |i|
        io << CharUtil.normalize(chars.unsafe_fetch(i))
      end
    end

    MtTerm.new(vstr, pecs, index &- start)
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

  class_getter pin_yin : self { new("core/pin_yin").load_db3! }
  class_getter hv_word : self { new("core/hv_word").load_db3! }
  class_getter hv_name : self { new("core/hv_name").load_db3!.load_tsv! }
end
