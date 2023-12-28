require "../../_util/char_util"

require "./qt_core/*"
require "./ws_core"

class MT::QtCore
  class_getter hv_word : self { new("word_hv") }
  class_getter hv_name : self { new("name_hv") }
  class_getter pin_yin : self { new("pin_yin") }

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

  def initialize(*dnames : String)
    @wseg = WsCore.load!(*dnames)
    @dicts = [] of HashDict
    dnames.each { |dname| @dicts << HashDict.load!(dname) }
    @dicts << HashDict.essence
    # @dicts <<  HashDict.new
  end

  def translate(str : String, cap : Bool = true)
    parse!(str).to_txt(cap: cap)
  end

  def to_mtl(str : String)
    parse!(str).to_mtl(cap: true)
  end

  def parse!(input : String, _idx = 0)
    output = QtData.new

    @wseg.parse!(input).each do |token|
      zstr = token.zstr
      size = zstr.size

      found = @dicts.each_with_index(1) do |dict, _dic|
        next unless defn = dict.any?(zstr)
        output << QtNode.new(zstr, defn.vstr, defn.attr, _idx: _idx, _dic: _dic)
        _idx &+= size
        break true
      end

      next if found

      vstr, attr = init_data(token.zstr, token.bner)
      output << QtNode.new(zstr, vstr, attr, _idx: _idx, _dic: -1)

      _idx += size
    end

    output
  end

  private def init_data(zstr : String, bner : MtEner = :none)
    vstr = CharUtil.normalize(zstr)
    return {vstr, MtAttr[Capx, Undb, Undn]} if vstr.blank?

    case bner
    when .link?, .dint?
      {vstr, MtAttr::Asis}
    when .punc?
      {vstr, MtAttr.parse_punct(zstr)}
    else
      {vstr, MtAttr::None}
    end
  end
end
