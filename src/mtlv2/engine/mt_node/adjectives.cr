require "./_generic"

module MtlV2::AST
  @[Flags]
  enum AdjtFlag : UInt8
    Adverbial # adjective that can act as verb adverb without de2
    Modifier  # adjective that can act as noun modifier without de1
    Adjtform  # word that act like adjective but do not combine with adverbs
    Measure   # can combine with measurement numeral after
  end

  class AdjtWord < BaseWord
    getter flag = AdjtFlag::None

    def initialize(term : V2Term)
      super(term)

      case term.tags[0][1]?
      when 'b'
        @flag |= AdjtFlag::Modifier
      when 'z', 'f'
        @flag |= AdjtFlag::Adjtform
      else
        # TODO: add words directly
        @flag |= AdjtFlag::Modifier if term.key.size < 3
        @flag |= AdjtFlag::Adverbial if term.key.size < 2
      end
    end
  end

  #########

  class AdjtNoun < BaseWord
    getter adjt_val : String? = nil
    getter adjt_tag : String = "a"

    getter noun_val : String? = nil
    getter noun_tag : String = "n"

    def initialize(term : V2Term)
      super(term)

      @adjt_val = term.vals[1]?
      @adjt_tag = term.tags[1]? || "a"

      @noun_val = term.vals[2]?
      @noun_tag = term.tags[2]? || "n"
    end
  end

  class AdjtAdvb < BaseWord
    getter adjt_val : String? = nil
    getter adjt_tag : String = "a"

    getter advb_val : String? = nil
    getter advb_tag : String = "d"

    def initialize(term : V2Term)
      super(term)

      @adjt_val = term.vals[1]?
      @adjt_tag = term.tags[1]? || "a"

      @advb_val = term.vals[2]?
      @advb_tag = term.tags[2]? || "d"
    end
  end

  class Hao3Word < BaseWord
    getter adjt_val = "tốt"
    getter advb_val = "thật"
  end

  ##################

  def self.adjt_from_term(term : V2Term)
    case term.tags[0][1]?
    when 'n' then AdjtNoun.new(term)
    when 'd' then AdjtAdvb.new(term)
    else          AdjtWord.new(term)
    end
  end
end
