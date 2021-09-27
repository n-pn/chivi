module CV::PadSpaces
  def pad_spaces!(node = @head) : self
    return self unless node = node.succ
    prev = node

    while node = node.succ
      node.set_prev(MtNode.new("", " ")) if should_space?(prev, node)
      prev = node unless node.val.empty?
    end

    self
  end

  def should_space?(left : MtNode, right : MtNode)
    return false if left.val.blank? || right.val.blank?

    case right.tag
    when .colon?  then return false
    when .middot? then return true
    when .quotecl?, .brackcl?, .titlecl?,
         .comma?, .penum?, .pstop?, .pdeci?,
         .smcln?, .exmark?, .qsmark?, .ellip?
      return left.tag.colon?
      # when .pdash?  then return !left.tag.puncts?
    when .quoteop?, .brackop?, .titleop?
      true
    when .puncts?
      case left.tag
      when .colon?, .comma?, .pstop?
        return true
      else
        return !left.tag.puncts?
      end
    end

    case left.tag
    when .quoteop?, .brackop?, .titleop?
      false
    else
      true
    end
  end
end
