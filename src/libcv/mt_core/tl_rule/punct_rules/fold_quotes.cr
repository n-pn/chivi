module CV::TlRule
  def fold_quoted!(head : MtNode) : MtNode
    return head unless char = head.val[0]?
    end_tag, end_val = match_end(char)

    tail = head
    while tail = tail.succ?
      # return head if tail.pstop? && !tag.quotecl?
      break if tail.tag.tag == end_tag && tail.val[0] == end_val
    end

    return head unless tail && tail != head.succ?

    root = fold!(head, tail, tag: PosTag::Unkn, dic: 0)
    fix_grammar!(root.body, level: 1)

    succ = head.succ
    if succ.succ? == tail
      root.dic = 1
      root.tag = succ.tag
    elsif root.prev? { |x| x.ude1? || x.pro_dems? || x.numeral? }
      root.tag = PosTag::NounPhrase
    end

    root.nominal? || root.strings? ? fold_nouns!(root) : root
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
end
