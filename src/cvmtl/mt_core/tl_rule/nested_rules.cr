module CV::TlRule
  def fold_puncts!(node : MtNode, mode = 1) : MtNode
    case node.tag
    when .quoteop?, .parenop?, .brackop?
      node = fold_nested!(node, mode: mode)
      node.nouns? ? fold_noun_left!(node, mode: mode) : node
    when .titleop?
      node = fold_ptitle!(node, mode: mode)

      node.body? ? fold_noun_left!(node, mode: mode) : node
    else
      node # TODO
    end
  end

  def fold_nested!(head : MtNode, mode = 1) : MtNode
    end_tag, end_val = match_end(head.val[0])

    tail = head
    while tail = tail.succ?
      break if tail.tag.tag == end_tag && tail.val[0] == end_val
    end

    return head unless tail && tail != head.succ?
    root = fold!(head, tail, tag: PosTag::Unkn, dic: 0)

    fix_grammar!(root.body, mode, level: 1)

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

  def fold_ptitle!(head : MtNode, mode = 1) : MtNode
    return head unless start_key = head.key[0]?
    end_key = match_title_end(start_key)

    tail = head

    while tail = tail.succ?
      break if tail.titlecl? && tail.key[0] == end_key
    end

    return head unless tail && tail != head.succ?
    root = fold!(head, tail, PosTag::Nother, dic: 0)

    fix_grammar!(head, mode)
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
