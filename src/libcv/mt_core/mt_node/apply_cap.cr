require "../../../cutil/text_utils"

module CV::MTL::ApplyCap
  def apply_cap!(cap : Bool = true) : self
    node = self

    while node
      cap = node.capitalize!(cap)
      node = node.succ?
    end

    self
  end

  def capitalize!(cap : Bool = false) : Bool
    return cap if @val == " "

    case @tag
    when .none?   then cap
    when .puncts? then cap_after_punct?(cap) # TODO: merge this with should_cap?
    when .urlstr? then false
    when .artstr? then false
    else
      @val = TextUtils.capitalize(@val) if cap
      false
    end
  end

  private def cap_after_punct?(prev = false) : Bool
    case @tag
    when .quoteop?, .exmark?, .qsmark?,
         .pstop?, .colon?, .middot?, .titleop?
      true
    when .pdeci?   then @prev.try { |x| x.numlat? || x.string? } || prev
    when .brackop? then true
      # when .parenop? then  prev
    else prev
    end
  end
end
