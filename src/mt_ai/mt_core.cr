require "./data/*"

class AI::MtCore
  def initialize(wn_id : String, uname : String)
    @dict = MtDict.new(wn_id, uname)
  end

  def translate(data : MtNode)
  end
end
