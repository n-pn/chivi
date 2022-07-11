require "./_generic"
require "./nominal"

module MtlV2::AST
  @[Flags]
  enum AdjtFlag : UInt8
    Adverbial # adjective that can act as verb adverb without de2
    Modifier  # adjective that can act as noun modifier without de1
    Adjtform  # word that act like adjective but do not combine with adverbs
    Measure   # can combine with measurement numeral after

    def self.from(tag : String, key : String) : AdjtFlag
      case tag[1]?
      when 'b'      then Modifier
      when 'z', 'f' then Adjtform
      else
        # TODO: map flag per words
        flag = term.key.size < 3 ? Modifier : None
        term.key.size < 2 ? flag | Adverbial : flag
      end
    end
  end

  class AdjtWord < BaseWord
    getter flag = AdjtFlag::None

    def initialize(term : V2Term, tag = term.tags[0])
      super(term)
      @flag = AdjtFlag.from(term.tags, term.key)
    end
  end

  #########

  class AdjtNoun < BaseWord
    getter adjt : AdjtWord
    getter noun : NounWord

    def initialize(term : V2Term)
      super(term)

      @adjt = AdjtWord.new(term, term.tags[2]? || "a")

      noun_tag = term.tags[1]? || "n"
      @noun = noun_tag[0]? == 'n' ? NounWord.new(term, noun_tag) : NameWord.new(term, noun_tag)
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
end
