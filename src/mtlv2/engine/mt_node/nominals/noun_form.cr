require "./noun_word"

module MtlV2::MTL
  class NounExpr < BaseExpr
    include Nominal

    def initialize(left : BaseNode, right : BaseNode, flip = false,
                   kind : NounKind = :ktetic)
      super(left, right, flip: flip)
    end
  end

  class NounForm < BaseForm
    getter noun : BaseNode

    property pmod : BaseNode | Nil = nil # prodem modidifer
    property nmod : BaseNode | Nil = nil # number modidifer
    property qmod : BaseNode | Nil = nil # quanti/nquant modifier

    property dmod : Ude1Expr | Nil = nil # modifier phrase with 的
    property amod : AdjtWord | Nil = nil # adjective modifier

    def initialize(@noun)
      self.set_succ(@noun.succ?)
      self.set_prev(@noun.prev?)
    end

    def to_list : Array(BaseNode)
      list = [noun]

      @amod.try { |x| add_to_list(list, x, x.noun_prefix?) }
      @dmod.try { |x| add_to_list(list, x, x.noun_prefix?) }
      @qmod.try { |x| add_to_list(list, x, true) }
      @nmod.try { |x| add_to_list(list, x, x.noun_prefix?) }
      @pmod.try { |x| add_to_list(list, x, x.noun_prefix?) }

      list
    end

    def add_to_list(list : Array(BaseNode), item : BaseNode, prefix : Bool = false)
      prefix ? list.unshift(item) : list.push(item)
    end
  end
end
