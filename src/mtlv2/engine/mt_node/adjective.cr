require "./nominal"
require "./adverbial"

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
    getter kind = AdjtAttr::None
    forward_missing_to @kind
  end

  class AdjtWord < BaseWord
    include Adjective

    def initialize(term : V2Term, pos = 0)
      super(term, pos)
      @kind = AdjtAttr.from(term.tags[pos]? || "a", term.key)
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

  class AdjtExpr < BaseExpr
    include Adjective

    def initialize(head : BaseNode, tail : BaseNode, flip = false,
                   @kind : AdjtAttr = :none)
      super(head, tail, flip: flip)
    end

    def initialize(orig : BaseExpr, tab = 0, @kind : AdjtAttr = :none)
      super(orig, tab)
    end
  end

  class AdjtForm
    include BaseNode
    include BaseSeri

    include Adjective

    getter adjt : BaseNode
    getter advb_prep : BaseNode? = nil # place advb before
    getter advb_post : BaseNode? = nil # place advb after

    def initialize(@adjt, advb : BaseNode?)
      self.set_succ(adjt.succ?)

      if advb
        self.add_advb(advb)
      else
        self.set_prev?(adjt.prev?)
        adjt.prev = nil
      end
    end

    def add_advb(advb : BaseNode)
      if advb.is_a?(AdvbWord) && advb.postpos?
        add_advb_post(advb)
      else
        add_advb_prep(advb)
      end
    end

    def add_advb_prep(advb : BaseNode)
      self.set_prev(advb.prev?)
      advb.prev = nil

      if prep = @advb_prep
        @advb_prep = AdvbPair.new(advb, prep)
      else
        @advb_prep = advb
      end
    end

    def add_advb_post(advb : BaseNode)
      self.set_prev(advb.prev?)
      advb.prev = nil

      if post = @advb_post
        @advb_post = AdvbPair.new(advb, post, flip: true)
      else
        @advb_post = advb
      end
    end

    def each
      @advb_prep.try { |x| yield x }
      yield adjt
      @advb_post.try { |x| yield x }
    end
  end
end
