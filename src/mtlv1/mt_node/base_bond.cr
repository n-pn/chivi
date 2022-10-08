require "./base_node"

class CV::BaseBond < CV::BaseNode
  include BaseExpr

  getter bond : BaseNode
  getter head : BaseNode
  getter tail : BaseNode

  def initialize(
    @bond : BaseNode, @head : BaseNode, @tail : BaseNode,
    @tag : PosTag = tail.tag, @dic : Int32 = 0, @idx : Int32 = head.idx,
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
