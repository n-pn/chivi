module CV::MTL::PadSpace
  def pad_spaces!(node = @head) : self
    return self unless node = node.succ
    prev = node

    while node = node.succ
      if node.tag.numlat? && (prev.tag.plsgn? || prev.tag.mnsgn?)
        node.tag = PosTag::String unless prev.prev.try(&.numlat?)
      elsif should_space?(prev, node)
        node.set_prev(MtNode.new("", " "))
      end

      prev = node unless node.val.empty?
    end

    self
  end

  def should_space?(left : MtNode, right : MtNode)
    return false if left.val.blank? || right.val.blank?

    case right.tag
    when .colon?  then return false
    when .middot? then return true
    when .plsgn?, .mnsgn?
      return false if left.tag.numlat?
    when .numlat?
      return false if left.tag.plsgn? || left.tag.mnsgn?
      # when .pdash?  then return !left.tag.puncts?
    when .quotecl?, .brackcl?, .titlecl?,
         .comma?, .penum?, .pstop?, .pdeci?,
         .smcln?, .exmark?, .qsmark?, .ellip?,
         .tilde?, .squanti?, .perct?
      return left.tag.colon?
    when .quoteop?, .brackop?, .titleop?
      return should_space_left?(left)
    when .puncts?
      case left.tag
      when .colon?, .comma?, .pstop? then return true
      else                                return !left.tag.puncts?
      end
    when .string?
      return false if left.tag.pdeci?
    end

    should_space_left?(left)
  end

  def should_space_left?(left : MtNode)
    case left.tag
    when .quoteop?, .brackop?, .titleop?
      false
    else
      true
    end
  end
end
