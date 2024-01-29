require "json"
require "../_raw/raw_con"
require "../../_util/char_util"
# require "../ai_dict"

require "./mt_dict"
require "./mt_rule/*"

class MT::AiCore
  CACHE = {} of String => self

  def self.load(pdict : String, udict : String = "qt0")
    CACHE["#{pdict}-#{udict}"] ||= new(pdict, udict: udict)
  end

  def initialize(pdict : String, udict : String = "qt0")
    @mt_dict = MtDict.for_mt(pdict, udict)
    @qt_core = QtCore.new(@mt_dict)

    @name_qt = QtCore.new(MtDict.hv_name(pdict))
  end

  def translate!(data : RawCon, prfx : MtNode)
    root = init_node(data, from: prfx.upto)
    root.prepend!(prfx)
  end

  def translate!(data : RawCon, prfx : Nil = nil)
    init_node(data, from: 0)
  end
end
