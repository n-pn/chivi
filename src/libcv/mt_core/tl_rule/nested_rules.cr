module CV::TlRule
  def fold_quotes!(node : MtNode, mode = 1) : MtNode
    end_char = matching_quote(node.val[0])

    last = tail = node

    while tail = tail.succ?
      break if tail.quotecl? && tail.val[0] == end_char
      last = tail
    end

    return node unless tail && node != last
    fold_phrase!(node, tail, last, mode: mode)
  end

  private def matching_quote(char : Char)
    case char
    when '“' then '”'
    when '‘' then '’'
    else          char
    end
  end

  def fold_phrase!(head : MtNode, tail : MtNode, last = tail.prev, mode = 1)
    head.body = body = head.succ

    head.fix_succ!(tail.succ?)
    tail.fix_succ!(nil)

    fix_grammar!(body, mode)

    head.tag = body.tag if tail == body.succ?
    head.fold = 1_i8

    head
  end
end
