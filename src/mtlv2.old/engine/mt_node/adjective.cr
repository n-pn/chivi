module MtlV2::MTL
  @[Flags]
  enum AdjtAttr : UInt8
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
      else               key.size < 2 ? NounMod | VerbAdv : None
      end
    end
  end

  module Adjective
    getter attr = AdjtAttr::None
    forward_missing_to @attr
  end

  class AdjtWord < BaseWord
    include Adjective

    def initialize(term : V2Term, pos = 0)
      super(term, pos)
      @attr = AdjtAttr.from(term.tags[pos]? || "a", term.key)
    end
  end

  #####

  class AdjtExpr < BaseExpr
    include Adjective

    def initialize(head : BaseNode, tail : BaseNode, flip = false,
                   @attr : AdjtAttr = :none)
      super(head, tail, flip: flip)
    end

    def initialize(orig : BaseExpr, tab = 0, @attr : AdjtAttr = :none)
      super(orig, tab)
    end
  end

  class AdjtForm
    include BaseSeri
    include Adjective

    getter adjt : BaseNode
    getter advb : Adverbial

    def initialize(@adjt, @advb : Adverbial)
      self.set_succ(adjt.succ?)
      self.set_prev(advb.prev?)
      adjt.set_succ(nil)
      advb.set_prev(nil)
    end

    def each
      yield @advb unless @advb.postpos?
      yield @adjt
      yield @advb if @advb.postpos?
    end
  end
end
