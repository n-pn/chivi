require "http/client"

require "./core/*"
require "./data/*"

class AI::MtCore
  def initialize(wn_id : Int32, uname : String = "")
    @dict = MtDict.new(wn_id, uname)
  end

  def translate(data : String, opts = MtOpts::Initial)
    translate(MtData.parse(data), opts)
  end

  def translate(data : MtNode, opts = MtOpts::Initial)
    String.build { |io| TextRenderer.new(io, @dict, opts).render(data) }
  end
end
