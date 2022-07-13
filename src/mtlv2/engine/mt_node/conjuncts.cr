require "./_generics"

module MtlV2::AST
  @[Flags]
  enum ConjunctType
    Phrase
    Clause

    def self.from(tag : String, key : String = "")
      case
      when tag[1]? == 'c'
        Phrase
      when {"但", "又", "或", "或是"}.includes?(key)
        Phrase | Clause
      else
        Clause
      end
    end
  end

  class Conjunct < BaseWord
    getter type : ConjunctType

    def initialize(
      term : V2Term,
      @type : ConjunctType = ConjunctType.from(term.tags[0], term.key)
    )
      super(term)
    end
  end
end
