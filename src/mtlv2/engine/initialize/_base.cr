module MtlV2::AST
  class BaseNode
    property idx : Int32 = 0
    property dic : Int32 = 0

    property key : String = ""
    property val : String = ""

    property! prev : BaseNode
    property! succ : BaseNode

    def initialize(@key = "", @val = @key, @dic = 0, @idx = 0)
    end

    def initialize(char : Char, @idx = 0)
      @key = @val = char.to_s
    end

    def initialize(term : V2Term)
      @key = term.key
      @val = term.vals.first
    end

    def dup!(idx : Int32, dic : Int32 = 1) : BaseNode
      target = self.dup
      target.idx = idx
      target.dic = dic
      target
    end

    def set_prev(@prev : BaseNode) : BaseNode
      prev.succ = self
      self
    end

    def set_prev(@prev : Nil) : BaseNode
      self
    end

    def set_succ(@succ : BaseNode) : BaseNode
      succ.prev = self
      self
    end

    def set_succ(@succ : Nil) : BaseNode
      self
    end

    def prev?
      @prev.try { |x| yield x }
    end

    def succ?
      @succ.try { |x| yield x }
    end
  end

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
  end

  class Mixed < BaseNode
  end
end
