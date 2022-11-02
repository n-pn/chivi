require "./pair_node"

class MT::NounPair < MT::PairNode
  def initialize(head : MtNode, tail : MtNode, flip = true)
    tag = head.tag == tail.tag ? head.tag : MtlTag::Nmix
    pos = head.pos | tail.pos
    super(head, tail, tag: tag, pos: pos, flip: flip)
  end
end
