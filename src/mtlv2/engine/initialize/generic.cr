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

    def initialize(term : V2Term, @dic = 0, @idx = 0)
      @key = term.key
      @val = term.vals.first
    end

    def dup!(idx : Int32, dic = self.dic) : BaseNode
      target = self.dup
      target.dic = dic
      target.idx = idx
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

  class BaseList
  end
end
