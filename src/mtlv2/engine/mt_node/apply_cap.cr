require "../../../_util/text_util"

class MtlV2::BaseNode
  def apply_cap!(cap : Bool = true) : Bool
    if body = @body
      cap = body.apply_cap!(cap)

      if body.brackop?
        prev = @prev || @root.try(&.prev?)
        cap = true if !prev || prev.none? || prev.pstops?
      end
    else
      cap = self.capitalize!(cap)
    end

    @succ.try(&.apply_cap!(cap: cap)) || cap
  end

  def capitalize!(cap : Bool = false) : Bool
    return cap if @val.blank?

    case @tag
    when .none?   then cap
    when .puncts? then cap_after_punct?(cap) # TODO: merge this with should_cap?
    when .fixstr? then false
    else
      @val = CV::TextUtil.capitalize(@val) if cap
      false
    end
  end

  private def cap_after_punct?(prev = false) : Bool
    case @tag
    when .quoteop?, .exmark?, .qsmark?,
         .pstop?, .colon?, .middot?, .titleop?
      true
    when .pdeci?   then @prev.try { |x| x.ndigit? || x.litstr? } || prev
    when .brackop? then true
      # when .parenop? then  prev
    else prev
    end
  end
end
