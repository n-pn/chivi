require "./mt_node"
require "./grammar/*"

class MTLV2::MTL::MtData
  def initialize(@tokens : Array(BaseNode))
  end
end
