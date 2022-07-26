require "../mt_words/*"
require "./ptcl_form"

module MtlV2::MTL
  class NounPair < BasePair
    include Nominal
  end

  class NounExpr < BaseExpr
    include Nominal

    def initialize(left : BaseNode, right : BaseNode, flip = false,
                   kind : NounKind = :ktetic)
      super(left, right, flip: flip)
    end
  end

  class NounForm < BaseForm
    getter noun : BaseNode

    property dem_mod : BaseNode | Nil = nil # prodem modidifer
    property num_mod : BaseNode | Nil = nil # number modidifer
    property qti_mod : BaseNode | Nil = nil # quanti/nquant modifier

    property de1_mod : Ude1Expr | Nil = nil # modifier phrase with 的
    property adj_mod : AdjtWord | Nil = nil # adjective modifier

    def initialize(@noun)
      self.set_succ(@noun.succ?)
      self.set_prev(@noun.prev?)
    end

    def to_list : Array(BaseNode)
      list = [noun]

      @adj_mod.try { |x| add_to_list(list, x, x.noun_prefix?) }
      @de1_mod.try { |x| add_to_list(list, x, x.noun_prefix?) }
      @qti_mod.try { |x| add_to_list(list, x, true) }
      @num_mod.try { |x| add_to_list(list, x, x.noun_prefix?) }
      @dem_mod.try { |x| add_to_list(list, x, x.noun_prefix?) }

      list
    end

    def add_to_list(list : Array(BaseNode), item : BaseNode, prefix : Bool = false)
      prefix ? list.unshift(item) : list.push(item)
    end
  end
end
