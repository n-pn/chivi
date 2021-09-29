require "../../../cutil/text_utils"

module MTL::ApplyCap
  def apply_cap!(cap : Bool = true) : self
    node = self
    node.capitalize! if cap

    while node = node.succ?
      case node.tag
      when .none?
        next
      when .puncts?
        cap = node.should_cap?(cap)
      else
        node.capitalize! if cap
        cap = false
      end
    end

    self
  end

  def capitalize! : Nil
    return if @tag.urlstr? || @tag.artstr? || @tag.none?
    @val = CV::TextUtils.capitalize(@val)
  end

  def should_cap?(prev = false) : Bool
    case @tag
    when .quoteop?, .exmark?, .qsmark?,
         .pstop?, .colon?, .middot?, .titleop?
      true
    when .brackop? then @val[0] == '(' ? prev : true
    when .puncts?  then prev
    else                false
    end
  end
end
