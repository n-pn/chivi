require "./_generic"

module MtlV2::AST
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
      ADVB_TYPES[key]?.try.reduce(val, None) { |flag, x| flag | parse(x) } || None
    end
  end

  enum AdvbKind
    Bu4
    Fei
    Mei
    Other

    def self.from_key(key : String)
      case term.key
      when "不" then Bu4
      when "没" then Mei
      when "非" then Fei
      else          Other
      end
    end
  end

  class AdvbWord < BaseWord
    getter flag : AdvbType
    getter kind : AdvbKind

    def initialize(
      term : V2Term,
      kind : AdvbKind = AdvbKind.from(term.key),
      flag : AdvbType = AdvbType.from(term.key)
    )
      super(term)
    end
  end

  def self.adverb_from_term(term : V2Term)
  end
end
