require "./base_word"

module MtlV2::MTL
  class BaseExpr < BaseNode
    property list = Deque(BaseNode).new

    def initialize(head : BaseNode, tail : BaseNode, @lbl = 0, flip = false)
      set_prev(head.prev?)
      set_succ(tail.succ?)

      head.fix_prev!(nil)
      tail.fix_succ!(nil)

      @list << head
      node = head.succ?

      while node && node != tail
        @list << node
        node = node.succ?
      end

      if flip
        @list.unshift(tail)
        tail.fix_succ!(head)

        @list.last.fix_succ!(nil)
        tail.fix_prev!(nil)
      else
        @list << tail
      end
    end

    def add_head(node : BaseNode) : Nil
      self.fix_prev!(node.prev?)
      @list.unshift(node)
    end

    def each
      @list.each do |node|
        yield node
      end
    end

    ##########

    def apply_cap!(cap : Bool = true)
      @list.reduce(cap) { |a, x| x.apply_cap!(a) }
    end

    def to_txt(io : IO) : Nil
      @list.first.to_txt(io)

      @list.each_cons_pair do |prev, node|
        io << ' ' if node.space_before?(prev)
        node.to_txt(io)
      end
    end

    def to_mtl(io : IO) : Nil
      io << '〈' << @lbl << '\t'
      @list.first.to_mtl(io)

      @list.each_cons_pair do |prev, node|
        io << "\t " if node.space_before?(prev)
        node.to_mtl(io)
      end

      io << '〉'
    end

    def inspect(io : IO, pad = -1) : Nil
      io << " " * pad if pad > 0
      io << '(' << self.klass << '/' << @lbl << ')' << '\n'
      @list.each(&.inspect(io, pad))
      io << '(' << '/' << self.klass << ')' << '\n'
      io << '\n' if pad >= 0
    end
  end
end
