module MtlV2::MTL
  # @[Flags]
  # enum BasePtag
  #   Adjective
  #   Nominal
  #   Verbal
  # end

  abstract class BaseNode
    property! prev : BaseNode
    property! succ : BaseNode

    property idx : Int32 = 0

    # getter ptag = BasePtag::None

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

    def replace!(target : BaseNode) : self
      set_prev(target.prev?)
      set_succ(target.succ?)
      target.unlink!
      self
    end

    def unlink!
      @prev = @succ = nil
    end

    abstract def apply_cap!
    abstract def to_txt(io : IO)
    abstract def to_mtl(io : IO)
    abstract def to_minspecttl(io : IO)

    def to_txt : String
      String.build { |io| to_txt(io) }
    end

    def to_mtl : String
      String.build { |io| to_mtl(io) }
    end

    def klass
      self.class.to_s.sub("MtlV2::AST::", "")
    end
  end
end
