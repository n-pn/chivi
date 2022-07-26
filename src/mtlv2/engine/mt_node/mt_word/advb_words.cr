require "../mt_base/*"

module MtlV2::MTL
  # references:
  # - https://chinemaster.com/pho-tu-trong-tieng-trung/

  ADVB_TYPES = QtranUtil.read_tsv("etc/cvmtl/adverbs.tsv")

  @[Flags]
  enum AdvbType
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

    def self.from(key : String)
      return None unless types = ADVB_TYPES[key]?
      types.reduce(None) { |flag, x| flag | parse(x) }
    end
  end

  module Adverbial
    getter type = AdvbType::None
    forward_missing_to @type

    def postpos?
      false
    end
  end

  class AdvbWord < BaseWord
    include Adverbial

    def initialize(term : V2Term, type : AdvbType = AdvbType.from(term.key))
      super(term)
    end
  end

  class AdvbBu4 < AdvbWord
  end

  class AdvbFei < AdvbWord
  end

  class AdvbMei < AdvbWord
  end
end
