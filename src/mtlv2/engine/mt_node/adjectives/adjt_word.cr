require "./adjt_form"

module MtlV2::MTL
  module Adjective
    getter flag = AdjtFlag::None
    forward_missing_to @flag
  end

  class AdjtWord < BaseWord
    include Adjective

    def initialize(term : V2Term, ptag = term.tags[0])
      super(term)
      @flag = AdjtFlag.from(term.tags[0], term.key)
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

    def to_list
      [@advb, @adjt]
    end
  end
end
