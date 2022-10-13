module MT::TlRule
  def fold_quoted!(head : BaseNode) : BaseNode
    return head unless char = head.val[0]?
    end_tag, end_val = match_end(char)

    tail = head
    while tail = tail.succ?
      # return head if tail.pstop? && !tag.quotecl?
      break if tail.tag.tag == end_tag && tail.val[0] == end_val
    end

    return head unless tail && tail != head.succ?

    root = fold!(head, tail, tag: PosTag::Unkn, dic: 0)
    fix_grammar!(root.body)

    succ = head.succ
    if succ.succ? == tail
      root.dic = 1
      root.tag = succ.tag
    elsif root.prev? { |x| x.pd_dep? || x.pro_dems? || x.numeral? }
      root.tag = PosTag::NounPhrase
    end

    root..noun_words? ? fold_nouns!(root) : root
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
