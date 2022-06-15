module CV::MtlV3::POS
  extend self

  class BaseNode
    property key : String = ""
    property val : String = ""

    property idx : Int32 = 0
    property dic : Int32 = 0

    # property tag : PosTag = PosTag::None

    property! prev : BaseNode
    property! succ : BaseNode

    def prev?
      return unless prev = @prev
      yield prev
    end

    def succ?
      return unless prev = @succ
      yield prev
    end

    def self.set_prev(prev : BaseNode) : BaseNode
      @prev = prev
      prev.succ = self
      self
    end

    def self.set_prev(@prev : Nil) : BaseNode
      self
    end

    def self.set_succ(succ : BaseNode) : BaseNode
      @succ = succ
      succ.prev = self
      self
    end

    def self.set_succ(@succ : Nil) : BaseNode
      self
    end

    def to_str
      String.build { |io| to_str(io) }
    end

    def to_str(io : IO)
      io << @val
    end
  end

  class BaseList < BaseNode
    property! head : BaseNode
    property! tail : BaseNode

    def add_head(node : MtNode)
      if head = @head
        node.set_succ(head.succ)
        @tail ||= node
      else
        @head = node
      end
    end

    def add_tail(node : MtNode)
      if tail = @tail
        node.set_prev(tail.prev)
        @head ||= node
      else
        @tail = node
      end
    end
  end

  # class BasePair < BaseNode
  #   getter left : BaseNode
  #   getter right : BaseNode

  #   def initialize(@left, @right, @idx = left.idx, @dic = 1, @swap = false)
  #     set_prev(@left.prev)
  #     @left.prev = nil

  #     set_succ(@right.succ)
  #     @right.succ = nil
  #   end
  # end
end
