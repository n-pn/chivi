require "./ai_data"
require "../data/*"

class MT::AiCore
  getter dict : AiDict

  def self.for_book(wn_id : Int32)
    new("book/#{wn_id}")
  end

  def initialize(pdict : String)
    @dict = AiDict.new(pdict)
  end

  def tl_from_con_data(data : String, cap = true, pad = false)
    mtdata = AiData.parse_con_data(data)
    translate(mtdata, cap: cap, pad: pad)
  end

  def translate(data : AiData, cap = true, pad = false)
    data.translate!(dict: @dict)
    data.to_txt(cap: cap, pad: pad)
  end
end
