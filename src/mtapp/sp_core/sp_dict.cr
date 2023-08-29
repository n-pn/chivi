require "./sp_term"

class MT::SpDict
  class_getter sino_vi : self { new("sino_vi") }
  class_getter pin_yin : self { new("pin_yin") }
  class_getter hv_name : self { new("hv_name") }

  @trie = Trie.new

  def initialize(dname : String)
    SpDefn.load_data(dname) do |zstr, vstr|
      next if vstr.empty?
      vstr = vstr.split('\t').first

      @trie[zstr] = SpTerm.new(zstr, vstr)
    end
  end

  def find_best(chars : Array(Char), start = 0) : SpTerm
    output = find_default_best(chars, start)

    node = @trie
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

    return SpTerm.new(first_char) unless first_char.alphanumeric?

    flag = FmtFlag::None
    index = start &+ 1

    while index < chars.size
      char = chars.unsafe_fetch(index)
      char = char - 32 if 'ａ' <= char <= 'ｚ'

      break unless '！' <= char <= '～'

      if char.alphanumeric?
        index &+= 1
      elsif chars[index &+ 1]?.try(&.alphanumeric?)
        flag |= :frozen
        index &+= 2
      else
        break
      end
    end

    vstr = chars[start...index].join
    SpTerm.new(vstr, len: index &- start, dic: 0, fmt: flag)
  end

  class Trie
    property data : SpTerm? = nil
    property trie = {} of Char => Trie

    def [](zstr : String)
      zstr.each_char.reduce(self) { |acc, char| acc.trie[char] ||= Trie.new }
    end

    def []=(zstr : String, data : SpTerm?)
      self[zstr].data = data
    end
  end
end
