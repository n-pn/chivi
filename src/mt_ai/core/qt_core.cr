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

  class_getter hv_word : self { new(MtDict.for_qt("word_hv")) }
  class_getter hv_name : self { new(MtDict.for_qt("name_hv")) }
  class_getter pin_yin : self { new(MtDict.for_qt("pin_yin")) }

  def initialize(@dict : MtDict)
    @wseg_core = WsCore.new(dict)
  end

  def translate(str : String, cap : Bool = true)
    parse!(str).to_txt(cap: cap)
  end

  def to_mtl(str : String)
    parse!(str).to_mtl(cap: true)
  end

  def parse!(input : String, _idx = 0)
    output = QtData.new

    @wseg_core.tokenize(input).each do |zstr|
      size = zstr.size

      if defn = @dict.any_defn?(zstr)
        output << QtNode.new(zstr, defn.vstr, defn.attr, _idx: _idx, _dic: defn.dnum.value)
      else
        vstr, attr = init_data(zstr)
        output << QtNode.new(zstr, vstr, attr, _idx: _idx, _dic: 0)
      end

      _idx += size
    end

    output
  end

  private def init_data(zstr : String)
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
