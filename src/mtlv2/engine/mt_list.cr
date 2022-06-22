require "./mt_node"
require "./tl_rule"

module MtlV2
  class BaseList < BaseNode
    property! head : BaseNode
    property! tail : BaseNode

    def add_head(node : BaseNode)
      node.set_succ(@head)
      self.set_prev(node.prev?)
      node.set_prev(nil)

      @tail ||= node
      @head = node
    end

    def add_tail(node : BaseNode)
      node.set_prev(@tail)
      self.set_succ(node.succ?)
      node.set_succ(nil)

      @head ||= node
      @tail = node
    end

    def each(node = @head)
      while node
        yield node
        node = node.succ?
      end
    end

    def apply_cap!(cap = true) : Bool
      @head.try(&.apply_cap!(cap)) || true
    end

    def fold!
      node = @head

      while node
        node.fold!(node.succ?)
        node = node.succ?
      end
    end
  end
end
