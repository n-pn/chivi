require "./_abstract"

module MtlV2::MTL
  class BaseExpr < BaseSeri
    property head : BaseNode
    property tail : BaseNode

    def initialize(head : BaseNode, tail : BaseNode,
                   flip = false, @tab = 0)
      set_prev(head.prev?)
      set_succ(tail.succ?)

      if flip
        @head, @tail = tail, tail.prev
        @tail.succ = tail.prev = nil
        head.succ, tail.prev = tail, head
      else
        @head, @tail = head, tail
        head.prev = tail.succ = nil
      end
    end

    def initialize(orig : BaseExpr, @tab = orig.tab)
      @head, @tail = orig.head, orig.tail
      set_prev(orig.prev?)
      set_succ(orig.succ?)
    end

    def add_head(node : BaseNode) : Nil
      self.set_prev(node.prev?)
      node.prev = nil
      @head.set_prev(node)
      @head = node
    end

    def add_tail(node : BaseNode) : Nil
      self.set_succ(node.succ?)
      node.succ = nil
      @tail.set_succ(node)
      @tail = node
    end

    def each
      node = @head

      while node
        yield node
        node = node.succ?
      end
    end
  end
end
