require "./_abstract"

module MtlV2::MTL
  class BasePair < BaseSeri
    property left : BaseNode
    property right : BaseNode

    def initialize(left : BaseNode, right : BaseNode, @flip = false)
      set_prev(left.prev?)
      set_right(right.succ?)

      if flip
        @left, @right = right, left
        left.succ = right.prev = nil
        right.succ, left.prev = left, right
      else
        @left, @right = left, right
        left.prev = right.succ = nil
      end
    end

    def each
      yield left
      yield right
    end

    def detact!
      left, right = flip ? {@right, @left} : {@left, @right}

      right.set_succ(@succ)
      left.set_succ(right)
      left.set_prev(@prev)

      @prev = @succ = nil

      {left, right}
    end
  end
end
