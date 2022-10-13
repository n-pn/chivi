require "./base_node/*"

class MT::TrioNode < MT::BaseNode
  include BaseExpr

  getter head : BaseNode
  getter body : BaseNode
  getter tail : BaseNode

  enum RenderType
    Normal    # head -> bond -> tail
    FlipAll   # tail -> bond -> head
    HeadLast  # bond -> tail -> head
    TailFirst # tail -> head -> bond
  end

  def initialize(
    @head : BaseNode, @body : BaseNode, @tail : BaseNode,
    @tag : MtlTag = tail.tag, @pos : MtlPos = tail.pos,
    @type : RenderType = :normal
  )
    self.fix_prev!(head.prev?)
    self.fix_succ!(tail.succ?)
  end

  def each
    case @type
    when .flip_all?
      yield @tail
      yield @body
      yield @head
    when .head_last?
      yield @body
      yield @tail
      yield @head
    when .tail_first?
      yield @tail
      yield @head
      yield @body
    else
      yield @head
      yield @body
      yield @tail
    end
  end
end
