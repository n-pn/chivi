require "./pair_node"

class MT::SubjPred < MT::PairNode
  include MtList

  def initialize(head : MtNode, tail : MtNode)
    super(head, tail)
  end
end
