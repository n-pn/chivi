module MtlV2::AST
  class BaseNode
    def fold!(succ : Nil) : BaseNode
      self
    end

    def fold!(succ = self.succ) : BaseNode
      self
    end

    def fold_left!(prev : Nil) : BaseNode
      self
    end

    def fold_left!(prev = self.prev) : BaseNode
      self
    end
  end
end
