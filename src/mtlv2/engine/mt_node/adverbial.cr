require "./_generic"

module MtlV2::MTL
  # references:
  # - https://chinemaster.com/pho-tu-trong-tieng-trung/

  ADVB_TYPES = QtranUtil.read_tsv("etc/cvmtl/adverbs.tsv")

  @[Flags]
  enum AdvbAttr
    # 否定副词 negative adverbs 否定 (fǒudìng) – An adverb that denies or negates
    # the action
    Nega

    # 时间副词 adverbs of time 时间 (shíjiān) – An adverb that adds context to
    # the amount of time that relates to action
    Time

    # 语气副词 modal adverbs/adverbs of mood
    # Adverbs of mood is an adverb that expresses doubt, conjecture, transition,
    # emphasis, etc.
    Mood

    # In What Range 范围 (fànwéi) – An adverb that specifies the range of
    # action
    Scope

    # To What Degree 程度 (chéngdù) – An adverb that specifies the degree of action
    Degree

    # How Often 频率 (pínlǜ) – An adverb that shows the frequency of action
    Freque

    # 关联副词 correlative or conjunctive adverbs
    # A correlative o conjunctive adverb is an adverb used in a phrase or sentence
    # for correlating two parts. Although correlative adverbs are used in the position
    # of an adverbial, it plays a significant role in correlating two parts. The
    # function of correlative adverbs is similar to that of 连词 conjunction.
    Correl

    # 情态副词/情状副词 adverbs of manner
    # Adverbs of manner describe the manner of doing an activity.     Manner

    Postpos

    # adverb that has special meanings
    Special

    Bu4; Fei; Mei

    def self.from_str(key : String)
      return None unless attrs = ADVB_TYPES[key]?
      attrs.reduce(None) { |flag, x| flag | parse(x) }
    end
  end

  module Adverbial
    getter attr = AdvbAttr::None
    forward_missing_to @attr
  end

  class AdvbWord < BaseWord
    include Adverbial

    def initialize(term : V2Term, pos : Int32 = 0)
      super(term, pos)
      @attr = AdvbAttr.from_str(term.key)
    end
  end

  class AdvbExpr < BaseExpr
    include Adverbial

    def initialize(head : Adverbial, tail : Adverbial, flip : Bool = false, tab : Int32 = 0)
      super(head, tail, flip: flip, tab: tab)
      @attr = head.attr | tail.attr
    end

    def add_head(node : Adverbial)
      super(node)
      @attr = @attr | node.attr
    end
  end
end
