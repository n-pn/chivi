require "../mt_word/*"

module MtlV2::MTL
  class Ude1Expr < BasePair
    def initialize(left : MtNode, ude1 : Ude1Word)
      super(left, ude1, flip: true)
    end

    def noun_prefix?
      false
    end
  end
end
