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

    property dem_mod : DemsproWord | ProNa2 | Nil = nil    # prodem modidifer
    property num_mod : NumberWord | Nil = nil              # number modidifer
    property qti_mod : QuantiWord | NquantWord | Nil = nil # quanti/nquant modifier

    property de1_mod : Ude1Expr | Nil = nil # modifier phrase with 的
    property adj_mod : AdjtWord | Nil = nil # adjective modifier

    def initialize(@noun)
      self.set_succ(@noun.succ?)
      self.set_prev(@noun.prev?)
    end

    # ameba:disable Metrics/CyclomaticComplexity
    def each : Nil
      if (dem_mod = @dem_mod) && dem_mod.noun_prefix?
        yield dem_mod
        dem_mod = nil
      end

      if (num_mod = @num_mod) && num_mod.noun_prefix?
        yield num_mod
        num_mod = nil
      end

      @qti_mod.try { |x| yield x }

      if (de1_mod = @de1_mod) && de1_mod.noun_prefix?
        yield de1_mod
        de1_mod = nil
      end

      if (adj_mod = @adj_mod) && adj_mod.noun_prefix?
        yield adj_mod
        adj_mod = nil
      end

      yield noun

      yield adj_mod if adj_mod
      yield de1_mod if de1_mod
      yield num_mod if num_mod
      yield dem_mod if dem_mod
    end
  end
end
