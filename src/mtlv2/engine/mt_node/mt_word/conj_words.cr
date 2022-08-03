require "../mt_base/*"

module MtlV2::MTL
  @[Flags]
  enum ConjType
    Coordi # coordinating conjunction
    Correl # correlative conjunction
    Subord # subordinating conjunction

    def self.from(key : String = "")
      if {"但", "又", "或", "或是"}.includes?(key)
        Coordi | Subord
      else
        Subord
      end
    end
  end

  class ConjWord < BaseWord
    getter type : ConjType

    def initialize(term : V2Term, @type : ConjType = :clause)
      super(term)
    end
  end

  ###

  def self.conj_from_term(term : V2Term, pos : Int32 = 0)
    tag = term.tags[pos]? || ""
    case tag[1]?
    when 'c' then ConjWord.new(term, :coordi)
    else          ConjWord.new(term, ConjType.from(term.key))
    end
  end
end
