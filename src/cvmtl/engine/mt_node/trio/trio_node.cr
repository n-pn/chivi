require "../mt_list"

class MT::TrioNode < MT::MtNode
  include MtList

  getter head : MtNode
  getter body : MtNode
  getter tail : MtNode

  enum RenderType
    Normal    # head -> bond -> tail
    FlipAll   # tail -> bond -> head
    FlipHead  # bond -> head -> tail
    FlipTail  # head -> tail -> bond
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
    when .flip_head?
      yield @body
      yield @head
      yield @tail
    when .flip_tail?
      yield @head
      yield @tail
      yield @body
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
