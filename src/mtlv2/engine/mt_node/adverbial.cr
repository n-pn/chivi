require "./_generic"

module MtlV2::AST
  ADVB_TYPES = QtranUtil.read_tsv("etc/cvmtl/advb-types.tsv")

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
    Correl

    def self.from(key : String)
      case ADVB_TYPES[key]?
      when "Ne" then Nega
      when "Ti" then Time
      when "Mo" then Mood
      when "Sc" then Scoop
      when "De" then Degree
      when "Fr" then Freque
      when "Co" then Correl
      else           None
      end
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
