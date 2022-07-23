require "./adjt_base"

module MtlV2::MTL
  class AdjtExpr < BaseExpr
    include Adjective

    def initialize(head : BaseNode, tail : BaseNode, flip = false,
                   kind : AdjtKind = :none)
      super(head, tail, flip: flip)
    end

    def initialize(orig : BaseExpr, kind : AdjtKind = :none)
      super(orig)
    end
  end

  class AdjtForm < BaseForm
    include Adjective

    getter adjt : BaseNode
    getter advb : AdvbWord | AdvbList

    def initialize(@adjt, @advb)
      self.set_succ(@adjt.succ?)
      self.set_prev(advb ? advb.prev? : adjt.prev?)
    end

    def add_advb(advb : AdvbWord)
      self.set_prev?(advb.prev?)

      case @advb
      when AdvbWord then @advb = AdvbList.new(advb, @advb)
      when AdvbList then @advb.add_head(advb)
      end
    end

    def to_list : Array(BaseNode)
      @advb.adjt_suffix? ? [@adjt, @advb] : [@advb, @adjt]
    end
  end
end
