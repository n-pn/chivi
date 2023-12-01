require "./ai_data"
require "../data/*"

class MT::AiCore
  getter dict : AiDict

  def initialize(pdict : String)
    @dict = AiDict.load(pdict)
  end

  def con_data_to_txt(data : String, cap = true, und = true)
    tl_from_con_data(data).to_txt(cap: cap, und: und)
  end

  def tl_from_con_data(data : String, rearrange : Bool = true) : AiData
    data = AiData.parse_con_data(data)
    data.translate!(dict: @dict, rearrange: rearrange)
  end
end
