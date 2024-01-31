require "./qt_core/*"
require "./ws_core"

class MT::QtCore
  def self.tl_hvname(str : String)
    return CharUtil.normalize(str) unless str.matches?(/\p{Han}/)
    self.hv_name.translate(str, cap: true)
  end

  def self.tl_hvword(str : String, cap : Bool = false)
    return CharUtil.normalize(str) unless str.matches?(/\p{Han}/)
    self.hv_word.translate(str, cap: cap)
  end

  def self.tl_pinyin(str : String, cap : Bool = false)
    return CharUtil.normalize(str) unless str.matches?(/\p{Han}/)
    self.pin_yin.translate(str, cap: cap)
  end

  class_getter pin_yin : self { new(MtDict.for_qt("pin_yin")) }
  class_getter hv_word : self { new(MtDict.for_qt("word_hv")) }
  class_getter hv_name : self { new(MtDict.for_qt("name_hv")) }

  class_getter name_qt : self { new(MtDict.name_hv("combine")) }
  class_getter noun_qt : self { new(MtDict.for_mt("noun_vi")) }
  class_getter verb_qt : self { new(MtDict.for_mt("verb_vi")) }
  class_getter adjt_qt : self { new(MtDict.for_mt("adjt_vi")) }
  class_getter nqmt_qt : self { new(MtDict.for_mt("nqmt_vi")) }

  def initialize(@dict : MtDict)
    @wseg_core = WsCore.new(dict)
  end

  def tl_noun(zstr : String)
    list = wrap_tokenize(zstr, :NN)

    # collect attr from last word
    attr = list.last.attr

    # swapping order
    # note: do not swap special words

    from = list[0].has_attr?(MtAttr[Prfx, At_h]) ? 1 : 0
    upto = list.size - 1
    upto -= 1 if list.last.has_attr?(MtAttr[Sufx, At_t])

    from.upto((upto &- from) // 2) do |i|
      j = upto &- i &+ from
      list[i], list[j] = list[j], list[i]
    end

    {list.to_txt(cap: false), attr}
  end

  @[AlwaysInline]
  def tl_name(zstr : String, wrap : Bool = true)
    data = wrap ? wrap_tokenize(zstr, :NR) : tokenize(zstr, :NR)
    data.unshift(data.pop) if data.last.has_attr?(MtAttr[Sufx, At_h])
    data.to_txt(cap: false)
  end

  @[AlwaysInline]
  def tl_term(zstr : String, epos : MtEpos = :X)
    wrap_tokenize(zstr).to_txt(cap: false)
  end

  def translate(zstr : String, cap : Bool = true)
    tokenize(zstr).to_txt(cap: cap)
  end

  def to_mtl(str : String)
    tokenize(str).to_mtl(cap: true)
  end

  @[AlwaysInline]
  def wrap_tokenize(zstr : String, epos : MtEpos = :X, _idx = 0)
    data = tokenize("∅#{zstr}∅", epos: epos, _idx: _idx)
    data.shift if data.first.zstr == "∅"
    data.pop if data.last.zstr == "∅"
    data
  end

  def tokenize(input : String, epos : MtEpos = :X, _idx = 0)
    tokens = @wseg_core.tokenize(input)
    output = QtData.new

    tokens.each do |zstr|
      size = zstr.size

      if defn = @dict.get_defn?(zstr, epos, true)
        output << QtNode.new(zstr, defn.vstr, defn.attr, _idx: _idx, _dic: defn.dnum.value)
      else
        vstr, attr = init_from_zstr(zstr)
        output << QtNode.new(zstr, vstr, attr, _idx: _idx, _dic: 0)
      end

      _idx &+= size
    end

    output
  end

  private def init_from_zstr(zstr : String)
    vstr = CharUtil.normalize(zstr)

    case vstr
    when .blank?
      {vstr, MtAttr[Capx, Undb, Undn]}
    when .starts_with?("http"), .starts_with?("www.")
      {vstr, MtAttr::Asis}
    when /^[\w\s]+/
      attr = MtAttr::None
      attr |= MtAttr::Undb if vstr.starts_with?(' ')
      attr |= MtAttr::Undn if vstr.ends_with?(' ')
      {vstr, attr}
    else
      {vstr, MtAttr.parse_punct(zstr)}
    end
  end
end
