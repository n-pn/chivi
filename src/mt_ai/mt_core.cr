require "http/client"

require "./core/*"
require "./data/*"

class AI::MtCore
  getter dict : MtDict

  def self.for_book(wn_id : Int32)
    new("book/#{wn_id}")
  end

  def initialize(pdict : String)
    @dict = MtDict.new(pdict)
  end

  def tl_from_con_data(data : String, apply_cap = true, pad_space = false)
    mtdata = MtData.parse_con_data(data)
    translate(mtdata, apply_cap: apply_cap, pad_space: pad_space)
  end

  def translate(data : MtData, apply_cap = true, pad_space = false)
    data.translate!(dict: @dict)
    data.to_txt(apply_cap: apply_cap, pad_space: pad_space)
  end
end
