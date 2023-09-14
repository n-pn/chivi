require "../data/*"

class MT::QtDict
  class_getter pin_yin : self { new(MtTrie.pin_yin) }
  class_getter hv_word : self { new(MtTrie.hv_word) }
  class_getter hv_name : self { new(MtTrie.hv_name) }

  def initialize(@main : MtTrie)
  end

  ###

  def find(chars : Array(Char), start = 0) : {MtTerm, Int32, Int32}
    existed = @main.find_best(chars, start) || MtTrie.essence.find_best(chars, start)
    initial = init(chars, start)

    existed && existed[1] >= initial[1] ? existed : initial
  end

  def init(chars : Array(Char), start = 0)
    first_char = chars.unsafe_fetch(start)

    unless CharUtil.fw_alnum?(first_char)
      return {MtTerm.from_char(first_char), 1, 4}
    end

    vstr = String::Builder.new
    vstr << CharUtil.normalize(first_char)
    attr = MtAttr::None

    index = start &+ 1

    while index < chars.size
      char = chars.unsafe_fetch(index)
      break unless '！' <= char <= '～'

      vstr << CharUtil.normalize(char)
      attr = MtAttr::Asis unless CharUtil.fw_alnum?(char)

      index &+= 1
    end

    {MtTerm.new(vstr.to_s, attr, 0_i8), index &- start, 5}
  end
end
