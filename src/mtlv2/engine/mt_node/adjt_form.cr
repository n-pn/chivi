require "./_generic"

module MtlV2::AST
  class AdjtForm < BaseForm
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
