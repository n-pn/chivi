require "../_raw/raw_con"
require "./ai_node/*"
require "./mt_core/*"

class MT::AiCore
  CACHE = {} of String => self

  def self.load(pdict : String)
    CACHE[pdict] ||= new(pdict.sub("book", "wn").tr(":/", ""))
  end

  @dicts : {HashDict, HashDict, HashDict, HashDict}

  def initialize(@pdict : String)
    @dicts = {
      HashDict.load!(pdict),
      HashDict.regular,
      HashDict.essence,
      HashDict.suggest,
    }

    @name_qt = QtCore.new(pdict, "name_hv")
  end

  def translate!(data : RawCon, prfx : AiWord)
    root = init_node(data, from: prfx.zstr.size)
    root.zstr = "#{prfx.zstr}#{root.zstr}"

    case root
    in AiWord
      root.tran = "#{prfx.tran}#{root.tran}"
    in AiCons
      root.tran.unshift(prfx)
    end

    root
  end

  def translate!(data : RawCon, prfx : Nil = nil)
    init_node(data, from: 0)
  end
end
