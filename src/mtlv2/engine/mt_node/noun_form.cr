require "./_generic"

module MtlV2::AST
  class NounForm < BaseForm
    getter noun : NounWord | NounList

    property prodem : BaseNode | Nil = nil
    property number : BaseNode | Nil = nil
    property quanti : BaseNode | Nil = nil

    property modifier : BaseNode | Nil = nil

    def initialize(@noun)
      self.set_succ(@noun.succ?)
      self.set_prev(@noun.prev?)
    end
  end
end
