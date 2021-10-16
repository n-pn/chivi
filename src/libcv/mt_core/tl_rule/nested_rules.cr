module CV::TlRule
  def fold_nested!(head : MtNode, mode = 1) : MtNode
    end_tag, end_val = match_end(head.val[0])
    tail = head

    while tail = tail.succ?
      break if tail.tag.tag == end_tag && tail.val[0] == end_val
    end

    return head unless tail && tail != head.succ?

    root = fold!(head, tail, dic: 1)

    succ = head.succ
    fix_grammar!(succ, mode)

    if tail == succ.succ?
      root.tag = succ.tag
    else
      root.dic = 0
    end

    root
  end

  private def match_end(char : Char)
    case char
    when '“' then {PosTag::Tag::Quotecl, '”'}
    when '‘' then {PosTag::Tag::Quotecl, '’'}
    when '(' then {PosTag::Tag::Parencl, ')'}
    when '[' then {PosTag::Tag::Brackcl, ']'}
    when '{' then {PosTag::Tag::Brackcl, '}'}
    else          {PosTag::Tag::Punct, char}
    end
  end

  def fold_ptitle!(head : MtNode, mode = 1) : MtNode
    end_key = match_title_end(head.key[0])
    tail = head

    while tail = tail.succ?
      break if tail.titlecl? && tail.key[0] == end_key
    end

    return head unless tail && tail != head.succ?

    fix_grammar!(head.succ, mode)
    fold!(head, tail, PosTag::Nother, dic: 0)
  end

  private def match_title_end(char : Char)
    case char
    when '《' then '》'
    when '〈' then '〉'
    when '⟨' then '⟩'
    when '<' then '>'
    else          char
    end
  end
end
