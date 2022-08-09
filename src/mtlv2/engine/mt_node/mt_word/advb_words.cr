require "../mt_base/*"

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

  class AdvbBu4 < AdvbWord
  end

  class AdvbFei < AdvbWord
  end

  class AdvbMei < AdvbWord
  end

  def self.advb_from_term(term : V2Term, pos : Int32 = 0)
    case term.key
    when "不" then AdvbBu4.new(term, pos: pos)
    when "没" then AdvbMei.new(term, pos: pos)
    when "非" then AdvbFei.new(term, pos: pos)
    else          AdvbWord.new(term, pos: pos)
    end
  end
end