module CV::MtlV2::TlRule
  def fold_btitle!(head : MtNode) : MtNode
    return head unless start_key = head.key[0]?
    end_key = match_title_end(start_key)

    tail = head

    while tail = tail.succ?
      break if tail.titlecl? && tail.key[0]? == end_key
    end

    return head unless tail && tail != head.succ?
    root = fold!(head, tail, PosTag::Btitle, dic: 0)

    fix_grammar!(root.body)
    fold_nouns!(root)
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
