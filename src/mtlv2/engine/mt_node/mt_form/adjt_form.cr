require "../mt_word/*"

module MtlV2::MTL
  class AdjtExpr < BaseExpr
    include Adjective

    def initialize(head : MtNode, tail : MtNode, flip = false,
                   @kind : AdjtKind = :none)
      super(head, tail, flip: flip)
    end

    def initialize(orig : BaseExpr, tab = 0, @kind : AdjtKind = :none)
      super(orig, tab)
    end
  end

  class AdjtForm
    include MtNode
    include MtSeri

    include Adjective

    getter adjt : MtNode
    getter advb_prep : MtNode? = nil # place advb before
    getter advb_post : MtNode? = nil # place advb after

    def initialize(@adjt, advb : MtNode?)
      self.set_succ(adjt.succ?)

      if advb
        self.add_advb(advb)
      else
        self.set_prev?(adjt.prev?)
        adjt.prev = nil
      end
    end

    def add_advb(advb : MtNode)
      if advb.is_a?(AdvbWord) && advb.postpos?
        add_advb_post(advb)
      else
        add_advb_prep(advb)
      end
    end

    def add_advb_prep(advb : MtNode)
      self.set_prev(advb.prev?)
      advb.prev = nil

      if prep = @advb_prep
        @advb_prep = AdvbPair.new(advb, prep)
      else
        @advb_prep = advb
      end
    end

    def add_advb_post(advb : MtNode)
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
