require "../data/*"

class MT::QtDict
  class_getter pin_yin : self { new("pin_yin") }
  class_getter hv_word : self { new("word_hv") }
  class_getter hv_name : self { new("name_hv") }

  BASE_TRIE = TrieDict.essence

  def initialize(dname : String)
    @pdict = TrieDict.load!(dname)
  end

  ###

  def find(chars : Array(Char), start = 0) : {MtTerm, Int32, Int32}
    existed = @pdict.match(chars, start) || BASE_TRIE.match(chars, start)

    initial = init(chars, start)

    existed && existed[1] >= initial[1] ? existed : initial
  end

  def init(chars : Array(Char), start = 0)
    first_char = chars.unsafe_fetch(start)

    unless CharUtil.fw_alnum?(first_char)
      return {MtTerm.new(first_char), 1, 4}
    end

    zstr = String::Builder.new
    vstr = String::Builder.new

    zstr << first_char
    vstr << CharUtil.normalize(first_char)

    attr = MtAttr::None

    index = start &+ 1

    while index < chars.size
      char = chars.unsafe_fetch(index)
      break unless '！' <= char <= '～'

      zstr << char
      vstr << CharUtil.normalize(char)

      attr = MtAttr::Asis unless CharUtil.fw_alnum?(char)

      index &+= 1
    end

    term = MtTerm.new(vstr: vstr.to_s, attr: attr, dnum: :autogen_0)
    {term, index &- start, 5}
  end
end
