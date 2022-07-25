module MtlV2::MTL
  class Ude1Expr < BasePair
    def initialize(left : BaseNode, ude1 : Ude1Word)
      super(left, ude1, flip: true)
    end
  end
end
