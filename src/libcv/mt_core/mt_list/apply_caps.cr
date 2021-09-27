module CV::ApplyCaps
  def capitalize!(node = @head, cap_mode = 1) : self
    while node = node.succ
      next if node.val.blank?

      if cap_mode > 0 && !node.tag.puncts?
        node.capitalize!(cap_mode) unless node.tag.strings?
        cap_mode = cap_mode == 2 ? 2 : 0
      else
        cap_mode = get_cap_mode(node, cap_mode)
      end
    end

    self
  end

  def get_cap_mode(node : MtNode, cap_prev : Int32 = 0) : Int32
    return node.tag.titlecl? ? 0 : 2 if cap_prev == 2

    case node.tag
    when .quoteop?, .exmark?, .qsmark?,
         .pstop?, .colon?, .middot?
      1
    when .titleop?           then 2
    when .brackop?           then node.val.starts_with?('(') ? cap_prev : 1
    when .strings?, .puncts? then cap_prev
    else                          0
    end
  end
end
