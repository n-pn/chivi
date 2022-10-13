require "./base_node/*"

class MT::BaseBond < MT::BaseNode
  include BaseExpr

  getter bond : BaseNode
  getter head : BaseNode
  getter tail : BaseNode

  def initialize(
    @bond : BaseNode, @head : BaseNode, @tail : BaseNode,
    @tag : MtlTag = tail.tag, @pos : MtlPos = tail.pos,
    @flip = false
  )
    self.fix_prev!(head.prev?)
    self.fix_succ!(tail.succ?)
  end

  def each
    yield @tail if @flip
    yield @head
    yield @bond
    yield @tail unless @flip
  end
end
