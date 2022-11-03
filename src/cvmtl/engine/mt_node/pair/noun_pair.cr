require "./pair_node"

class MT::NounPair < MT::PairNode
  def initialize(head : MtNode, tail : MtNode,
                 tag = head.tag == tail.tag ? head.tag : MtlTag::Nmix,
                 pos = head.pos | tail.pos,
                 flip = true)
    super(head, tail, tag: tag, pos: pos, flip: flip)
  end

  def detach!
    @head.fix_prev!(@prev)
    @tail.fix_succ!(@succ)
    @prev = @succ = nil
    {head, @tail}
  end
end
