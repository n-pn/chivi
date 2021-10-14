module CV::TlRule
  def fold_quotes!(node : MtNode, mode = 1) : MtNode
    end_char = matching_quote(node.val[0])

    last = tail = node

    while tail = tail.succ?
      break if tail.quotecl? && tail.val[0] == end_char
      last = tail
    end

    return node unless tail && node != last

    fold_phrase!(node, tail, mode: mode)
  end

  private def matching_quote(char : Char)
    case char
    when '“' then '”'
    when '‘' then '’'
    else          char
    end
  end

  def fold_phrase!(head : MtNode, tail : MtNode, mode = 1)
    root = MtNode.fold!(head, tail, dic: 1)
    succ = head.succ

    fix_grammar!(succ, mode)
    # root.tag = succ.tag if tail == succ.succ?

    root
  end
end
