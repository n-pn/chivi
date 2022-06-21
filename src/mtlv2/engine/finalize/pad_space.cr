module MtlV2::AST
  class BaseNode
    def space_before?(prev : Nil)
      false
    end

    def space_before?(prev = self.prev)
      true
    end

    def space_after?(prev : Nil)
      false
    end

    def space_after?(prev = self.prev)
      true
    end
  end

  class Punct
    def space_before?(prev = self.prev?)
      false
    end

    def space_after?(succ = self.succ?)
      false
    end
  end

  class BaseList
    def pad_spaces!
      return unless node = @head

      while succ = node.succ?
        if node.space_after? || succ.space_before?
          whitespace = Whitespace.new("", " ", idx: @idx)
          succ.set_prev(whitespace)
        end

        node = succ
      end
    end

    # # ameba:disable Metrics/CyclomaticComplexity
    # def should_space_before?(prev : BaseNode) : Bool
    #   return false if prev.val.blank?

    #   case @tag
    #   when .litstr? then return false if prev.tag.pdeci?
    #   when .ndigit? then return false if prev.tag.plsgn? || prev.tag.mnsgn?
    #   when .plsgn?  then return false if prev.tag.ndigit?
    #   when .mnsgn?  then return false if prev.tag.ndigit?
    #   when .colon?  then return false
    #   when .middot? then return true
    #   when .ptitle?
    #     return false if prev.popens?
    #     return @key[0] == '-' ? false : true
    #   when .popens? then return !prev.popens?
    #   when .puncts?
    #     case @tag
    #     # when .pdash?  then return !prev.tag.puncts?
    #     when .pstops?, .comma?, .penum?,
    #          .pdeci?, .ellip?, .tilde?,
    #          .perct?, .squanti?
    #       return prev.tag.colon?
    #     else
    #       case prev.tag
    #       when .colon?, .comma?, .pstop? then return true
    #       else                                return !prev.puncts?
    #       end
    #     end
    #   end

    #   !prev.popens?
    # end
  end
end
