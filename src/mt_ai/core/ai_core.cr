require "json"
require "../_raw/raw_con"
require "../../_util/char_util"
# require "../ai_dict"

require "./mt_dict"
require "./mt_rule/*"

class MT::AiCore
  CACHE = {} of String => self

  def self.load(pdict : String)
    CACHE[pdict] ||= new(pdict)
  end

  def initialize(pdict : String)
    @mt_dict = MtDict.for_mt(pdict)
    @name_qt = QtCore.new(MtDict.hv_name(pdict))
  end

  def translate!(data : RawCon, prfx : MtTerm)
    root = init_node(data, from: prfx.upto)
    root.prepend!(prfx)
  end

  def translate!(data : RawCon, prfx : Nil = nil)
    init_node(data, from: 0)
  end
end
