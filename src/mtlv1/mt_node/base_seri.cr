require "./base_node"

class CV::BaseSeri < CV::BaseNode
  include BaseExpr

  def initialize(@head : BaseNode, @tail : BaseNode,
                 @tag : PosTag = PosTag::LitBlank,
                 @dic = 0, @idx = head.idx, flip = false)
    self.fix_prev!(head.prev?)
    self.fix_succ!(tail.succ?)

    head.fix_prev!(nil)
    tail.fix_succ!(nil)

    if flip
      @tail = tail.prev
      @head = tail
      @head.fix_succ!(head)
    end

    @head.fix_prev!(nil)
    @tail.fix_succ!(nil)
  end

  def each
    node = @head
    yield node

    while node = node.succ?
      yield node
      break if node == @tail
    end
  end
end
