module CV::TlRule
  def fold_nested!(node : MtNode) : MtNode
    node.tag.titleop? ? fold_ptitle!(node) : fold_quoted!(node)
  end

  def fold_quoted!(head : MtNode) : MtNode
    end_tag, end_val = match_end(head.val[0])

    tail = head
    while tail = tail.succ?
      # return head if tail.pstop? && !tag.quotecl?
      break if tail.tag.tag == end_tag && tail.val[0] == end_val
    end

    return head unless tail && tail != head.succ?

    tag = head.prev?(&.ude1?) ? PosTag::NounPhrase : PosTag::Unkn
    root = fold!(head, tail, tag: tag, dic: 0)

    fix_grammar!(root.body, level: 1)

    succ = head.succ
    if succ.succ? == tail
      root.dic = 1
      root.tag = succ.tag
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

  def fold_ptitle!(head : MtNode) : MtNode
    return head unless start_key = head.key[0]?
    end_key = match_title_end(start_key)

    tail = head

    while tail = tail.succ?
      break if tail.titlecl? && tail.key[0] == end_key
    end

    return head unless tail && tail != head.succ?
    root = fold!(head, tail, PosTag::Nother, dic: 0)

    fix_grammar!(head)
    root
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
