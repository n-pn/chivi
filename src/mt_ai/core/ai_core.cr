require "./ai_data"
require "../data/*"

class MT::AiCore
  getter dict : AiDict

  def self.for_book(wn_id : Int32)
    new("book/#{wn_id}")
  end

  def initialize(pdict : String, @tl_phrase : Bool = true)
    @dict = AiDict.new(pdict)
  end

  def con_data_to_txt(data : String, cap = true, pad = false)
    tl_from_con_data(data).to_txt(cap: cap, pad: pad)
  end

  def tl_from_con_data(data : String) : AiData
    data = AiData.parse_con_data(data)
    data.tl_phrase!(dict: @dict)
    data
  end
end
