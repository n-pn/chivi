require "../mt_base/*"
require "./noun_words"
require "./advb_words"

module MtlV2::MTL
  @[Flags]
  enum AdjtKind : UInt8
    VerbAdv # adjective that can act as verb adverb without de2
    NounMod # adjective that can act as noun modifier without de1

    VerbSuffix # when combine with verb always places after
    NounPrefix # when combine with noun always places before

    # word that act like adjective but do not combine with adverbs
    # can only combine with noun/verb in present of particle de1/de2
    Express

    # can combine with measurement numeral after
    Measure

    # adjective can act as nouns
    Nominal

    def self.from(tag : String, key : String) : self
      return flags(NounMod, NounPrefix) if key.in?("原", "所有")

      case tag[1]?
      when 'b'      then NounMod
      when 'z', 'f' then Express
      when 'm'      then Measure
      else
        term.key.size < 2 ? Nounmod | VerbAdv : None
      end
    end
  end

  module Adjective
    getter kind = AdjtKind::None
    forward_missing_to @kind
  end

  class AdjtWord < BaseWord
    include Adjective

    def initialize(term : V2Term, pos = 0)
      super(term, pos)
      @kind = AdjtKind.from(term.tags[pos]? || "a", term.key)
    end
  end

  class AjnoWord < BaseWord
    getter adjt : AdjtWord { AdjtWord.new(@key, @val, @tab, @idx) }
    getter noun : NounWord { NounWord.new(@key, @val, @tab, @idx) }

    def initialize(term : V2Term, pos = 0)
      super(term, pos)
      @noun = NounWord.new(term, pos &* 2 &+ 1)
      @adjt = AdjtWord.new(term, pos &* 2 &+ 2)
    end
  end

  class AjadWord < BaseWord
    getter adjt : AdjtWord { AdjtWord.new(@key, @val, @tab, @idx) }
    getter advb : AdvbWord { AdvbWord.new(@key, @val, @tab, @idx) }

    def initialize(term : V2Term, pos = 0)
      super(term, pos)
      @advb = AdvbWord.new(term, pos &* 2 &+ 1)
      @adjt = AdjtWord.new(term, pos &* 2 &+ 2)
    end
  end

  #####

  def self.adjt_from_term(term : V2Term, pos : Int32 = 0)
    tag = term.tags[pos]? || ""
    case tag[1]?
    when 'n' then AjnoWord.new(term, pos: pos)
    when 'd' then AjadWord.new(term, pos: pos)
    else          AdjtWord.new(term, pos: pos)
    end
  end
end
