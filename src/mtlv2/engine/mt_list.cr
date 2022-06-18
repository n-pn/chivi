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

    def to_s : String
      String.build { |io| to_s(io) }
    end

    def to_s(io : IO) : Nil
      @head.try(&.print_val(io))
    end

    def to_mtl : String
      String.build { |io| to_mtl(io) }
    end

    def to_mtl(io : IO) : Nil
      @head.try(&.serialize(io))
    end

    def inspect(io : IO) : Nil
      @head.try(&.deep_inspect(io))
    end

    def apply_cap!(cap = true) : Bool
      @head.try(&.apply_cap!(cap)) || true
    end

    def pad_spaces! : self
      if (head = @head) && (succ = head.succ?)
        succ.pad_spaces!(head)
      end

      self
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
