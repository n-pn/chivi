require "./_generics"

module MtlV2::AST
  @[Flags]
  enum AdjtFlag : UInt8
    Adverbial # adjective that can act as verb adverb without de2

    Modifier # adjective that can act as noun modifier without de1
    Adjtform # word that act like adjective but do not combine with adverbs

    Measure # can combine with measurement numeral after
    Nominal # adjective can act as nouns

    def self.from(tag : String, key : String) : self
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

    def initialize(
      term : V2Term,
      @flag : AdjtFlag = AdjtFlag.from(term.tags[0], term.key)
    )
      super(term)
    end
  end
end
