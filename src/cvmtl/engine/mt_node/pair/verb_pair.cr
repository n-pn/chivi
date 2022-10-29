require "./pair_node"

class MT::VerbPair < MT::PairNode
  include MtList

  def initialize(head : MtNode, tail : MtNode)
    tag = MtlTag::Vmix
    pos = head.pos | tail.pos
    super(head, tail, tag: tag, pos: pos)
  end

  def add_objt(objt : MtNode)
    self.fix_succ!(objt.succ?)
    objt.fix_cucc!(nil)

    tail = @tail
    tail = VerbExpr.new(tail) unless tail.is_a?(VerbExpr)
    tail.add_objt(objt)
  end
end
