require "../data/*"

class MT::QtDict
  ###

  @data = Trie.new

  def initialize(@dname : String)
  end

  def load_tsv!(dname : String = @dname)
    File.each_line(MtDefn.db_path(dname, "tsv")) do |line|
      cols = line.split('\t')
      next if cols.size > 2
      add_term(cols[0], cols[2], MtPecs.parse_line(ipecs))
    end

    self
  end

  def load_db3!(dname : String = @dname)
    MtDefn.db(dname).open_ro do |db|
      db.query_each("select zstr, vstr, ipecs from terms") do |rs|
        zstr, vstr, ipecs = rs.read(String, String, Int32)
        vstr = vstr.split('\t').first
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

  def find_best(chars : Array(Char), start = 0) : MtTerm
    output = find_default_best(chars, start)

    node = @data
    start.upto(chars.size &- 1) do |idx|
      char = chars.unsafe_fetch(idx)
      char = char - 32 if 'ａ' <= char <= 'ｚ'

      break unless node = node.trie[char]?

      node.data.try { |data| output = data if output.len <= data.len }
    end

    output
  end

  def find_default_best(chars : Array(Char), start = 0)
    first_char = chars.unsafe_fetch(start)
    first_char = first_char - 32 if 'ａ' <= first_char <= 'ｚ'

    return MtTerm.from_char(first_char) unless first_char.alphanumeric?

    pecs = MtPecs::None
    index = start &+ 1

    while index < chars.size
      char = chars.unsafe_fetch(index)
      char = char - 32 if 'ａ' <= char <= 'ｚ'

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

    vstr = chars[start...index].join
    {MtTerm.new(vstr, pecs), 0, index &- start}
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

  class_getter sino_vi : self { new("sino_vi") }
  class_getter pin_yin : self { new("pin_yin") }
  class_getter hv_name : self { new("hv_name") }
end
