require "../mt_word/*"
require "./ptcl_form"

module MtlV2::MTL
  class NounPair < BasePair
    include Nominal
  end

  class NounExpr < BaseExpr
    include Nominal

    def initialize(head : MtNode, tail : MtNode, flip = false)
      super(head, tail, flip: flip)
    end
  end

  class NounForm
    include MtNode
    include MtSeri
    include Nominal

    getter noun : MtNode

    property dem_mod : MtNode | Nil = nil # prodem modidifer
    property num_mod : MtNode | Nil = nil # number modidifer
    property qti_mod : MtNode | Nil = nil # quanti/nquant modifier

    property de1_mod : Ude1Expr | Nil = nil # modifier phrase with 的
    property adj_mod : AdjtWord | Nil = nil # adjective modifier

    def initialize(@noun)
      self.set_succ(@noun.succ?)
      self.set_prev(@noun.prev?)
    end

    # ameba:disable Metrics/CyclomaticComplexity
    def each
      if (dem_mod = @dem_mod) && dem_mod.noun_prefix?
        yield dem_mod
        dem_mode = nil
      end

      if (num_mod = @num_mod) && num_mod.noun_prefix?
        yield num_mod
        num_mode = nil
      end

      @qti_mod.try { |x| yield x }

      if (de1_mod = @de1_mod) && de1_mod.noun_prefix?
        yield de1_mode
        de1_mod = nil
      end

      if (adj_mod = @adj_mod) && adj_mod.noun_prefix?
        yield adj_mode
        adj_mod = nil
      end

      yield noun

      yield adj_mode if adj_mod
      yield de1_mode if de1_mod
      yield num_mode if num_mod
      yield dem_mode if dem_mod

      list
    end
  end
end
