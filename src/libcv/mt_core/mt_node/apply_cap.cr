require "../../../cutil/text_utils"

module MTL::ApplyCap
  def apply_cap!(cap : Bool = true) : self
    node = self
    node.capitalize! if cap

    while node = node.succ?
      next if node.val.blank?

      if cap && !node.tag.puncts?
        node.capitalize!
        cap = false
      else
        cap = node.should_cap?(cap)
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
      # when .brackop?           then @val.starts_with?('(') ? prev : true
    when .brackop? then true
    when .strings? then prev
    when .puncts?  then prev
    else                false
    end
  end
end
