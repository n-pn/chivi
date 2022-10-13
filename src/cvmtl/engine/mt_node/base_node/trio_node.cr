require "../mt_node"

class MT::TrioNode < MT::MtNode
  include BaseExpr

  getter head : MtNode
  getter body : MtNode
  getter tail : MtNode

  enum RenderType
    Normal    # head -> bond -> tail
    FlipAll   # tail -> bond -> head
    HeadLast  # bond -> tail -> head
    TailFirst # tail -> head -> bond
  end

  def initialize(
    @head : MtNode, @body : MtNode, @tail : MtNode,
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
