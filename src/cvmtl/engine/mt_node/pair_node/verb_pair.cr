require "./pair_node"

class MT::VerbPair < MT::PairNode
  include MtList

  def initialize(head : MtNode, tail : MtNode)
    tag = MtlTag::Vform
    pos = head.pos | tail.pos
    super(head, tail, tag: tag, pos: pos)
  end

  def add_objt(objt : MtNode)
    self.fix_succ!(objt.succ?)
    objt.fix_cucc!(nil)

    tail = @tail
    tail = VerbForm.new(tail) unless tail.is_a?(VerbForm)
    tail.add_objt(objt)
  end
end
