require "./_generic"

module MtlV2::MTL
  @[Flags]
  enum NounAttr
    # https://khoahoctiengtrung.com/danh-tu-trong-tieng-trung/

    # generic

    Ktetic # possessives noun
    Locale # place or location

    # 专有名词
    # https://baike.baidu.com/item/%E4%B8%93%E6%9C%89%E5%90%8D%E8%AF%8D/3543467
    Proper

    Person # noun refer human
    Living # animate noun

    # # future

    # 个体名词 individual noun
    # https://baike.baidu.com/item/%E4%B8%AA%E4%BD%93%E5%90%8D%E8%AF%8D/2894284
    Individ

    # 集体名词 collective Noun
    # https://baike.baidu.com/item/%E9%9B%86%E4%BD%93%E5%90%8D%E8%AF%8D/4368019
    Collect

    # 抽象名词
    # https://baike.baidu.com/item/%E6%8A%BD%E8%B1%A1%E5%90%8D%E8%AF%8D/417488
    Abstract

    # 物质名词
    # https://baike.baidu.com/item/%E7%89%A9%E8%B4%A8%E5%90%8D%E8%AF%8D/10670685
    Material

    # Specific

    # norrmal
    Honor
    Trait
    Abstr

    Basic
    Place
    Posit
    Locat

    # proper

    Human
    Affil
    Title
    Other

    def self.from_tag(tag : String)
      tag[0] == 'n' ? common_tag(tag) : proper_tag(tag)
    end

    def self.common_tag(tag : String)
      case tag[1]?
      when 'h' then Honor | Person | Ktetic | Material
      when 'p' then Place | Locale | Ktetic | Material
      when 's' then Posit | Locale
      when 'f' then Locat
      when 'a' then Trait | Abstract
      when 'b' then Abstr | Abstract
      else          Basic | Ktetic | Material
      end
    end

    def self.proper_tag(tag : String)
      case tag[1]?
      when 'r' then Human | Person | Ktetic | Proper
      when 'a' then Human | Locale | Ktetic | Proper
      when 'w' then Title | Ktetic | Proper
      else          Other | Ktetic | Proper
      end
    end

    # def self.affil_from_term(term : V2Term, pos : Int32 = 0)
    #   case tags[2]?
    #   when 'l' then PlaceName.new(term, pos: pos)
    #   when 'g' then InstiName.new(term, pos: pos)
    #   else          AffilName.new(term, pos: pos)
    #   end
    # end
  end

  #########

  module Nominal
    getter attr : NounAttr = NounAttr::Ktetic
    forward_missing_to @attr

    def human?
      @attr.includes?(NounAttr.flags(Honor, Human, Affil, Basic))
    end

    def self.from_term(term : V2Term, pos : Int32 = 0)
      tag = term.tags[pos]? || "n"
      return NameWord.new(term, pos) if tag[0]? == 'N'

      case tag[1]?
      when 'h' then HonorNoun.new(term, pos)
      when 'f' then LocatNoun.new(term, pos)
      when 't' then TimeWord.new(term, pos)
      else          NounWord.new(term, pos)
      end
    end
  end

  class NounWord < BaseWord
    include Nominal

    def initialize(term : V2Term, pos : Int32 = 0)
      super(term, pos)
      @attr = NounAttr.from_tag(term.tags[pos]? || "n")
    end

    def initialize(@key : String, @val : String, @tab : Int32 = 0, @idx : Int32 = 0)
    end
  end

  class NameWord < NounWord
    def initialize(term : V2Term, pos : Int32 = 0)
      super(term, pos)
      @attr = NounAttr.proper_tag(term.tags[pos]? || "N")
    end
  end

  class HonorNoun < NounWord
    getter mold : String

    def initialize(term : V2Term, pos : Int32 = 1)
      super(term, pos)

      if (alt = term.vals[pos]?) && alt.includes?("?")
        @mold = alt
      else
        @mold = "? " + @val
      end
    end

    def apply_honor(name : String)
      @mold.sub("?", name)
    end
  end

  class LocatNoun < NounWord
    def initialize(term : V2Term, pos : Int32 = 1)
      super(term, pos)
      @attr |= NounAttr::Locale if @key.size > 1
    end
  end

  @[Flags]
  enum TimeType
    When # datetime
    Span # duration
    Else # other type
  end

  class TimeWord < NounWord
    getter type : TimeType = TimeType::None

    def initialize(term : V2Term, pos : Int32 = 1)
      super(term, pos)
      # TODO: map time type
    end
  end

  ######

  class NounPair < BasePair
    include Nominal

    def initialize(left : BaseNode, right : Nominal, flip = false, @attr = right.attr)
      super(left, right, flip)
    end
  end

  class TimePair < BasePair
  end

  class NounExpr < BaseExpr
    include Nominal

    def initialize(head : BaseNode, tail : BaseNode, flip = false)
      super(head, tail, flip: flip)
    end
  end

  class NounForm
    include BaseSeri
    include Nominal

    getter noun : BaseNode

    property dem_mod : DemsproWord | ProNa2 | Nil = nil    # prodem modidifer
    property num_mod : NumberWord | Nil = nil              # number modidifer
    property qti_mod : QuantiWord | NquantWord | Nil = nil # quanti/nquant modifier

    property de1_mod : Ude1Pair | Nil = nil # modifier phrase with 的
    property adj_mod : AdjtWord | Nil = nil # adjective modifier

    def initialize(@noun)
      self.set_succ(@noun.succ?)
      self.set_prev(@noun.prev?)
    end

    def add_quanti(node : QuantiWord | NquantWord)
      self.set_prev(node.prev?)
      @qti_mod = node.as_quanti!
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
