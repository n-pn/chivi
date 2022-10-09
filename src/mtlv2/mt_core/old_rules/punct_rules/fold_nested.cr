module MT::TlRule
  def map_closer_char(char : Char)
    case char
    when '《' then '》'
    when '〈' then '〉'
    when '⟨' then '⟩'
    when '<' then '>'
    when '“' then '”'
    when '‘' then '’'
    when '(' then ')'
    when '[' then ']'
    when '{' then '}'
    else          char
    end
  end

  def fold_nested!(head : BaseNode, tail : BaseNode)
    fold_list!(head, tail)
    ptag = guess_nested_tag(head, tail)
    list = fold!(head, tail, tag: ptag, dic: 0)
    # list.inspect
    list
  end

  def guess_nested_tag(head : BaseNode, tail : BaseNode)
    case head.tag
    when .title_sts? then MapTag::CapTitle
    when .brack_sts? then MapTag::CapOther
    when .paren_st1? then MapTag::ParenExp
    else                  guess_quoted_tag(head, tail)
    end
  end

  def guess_quoted_tag(head : BaseNode, tail : BaseNode)
    head_succ = head.succ
    tail_prev = tail.prev

    if head_succ == tail_prev
      return head_succ.tag unless head_succ.tag.polysemy?
      return heal_mixed!(head_succ, head.prev?, tail.succ?).tag
    end

    if (tail_prev.interj? || tail_prev.pt_dep?) &&
       (head_succ.onomat? || head_succ.interj?) &&
       (head.prev?(&.boundary?.!) || tail.succ?(&.pt_dep?))
      return head_succ.tag
    end

    head.prev?(&.pt_dep?) ? MapTag::Nform : MapTag::LitBlank
  end

  # def fold_btitle!(head : BaseNode) : BaseNode
  #   return head unless start_key = head.key[0]?
  #   end_key = match_title_end(start_key)

  #   tail = head

  #   while tail = tail.succ?
  #     break if tail.titlecl? && tail.key[0]? == end_key
  #   end

  #   return head unless tail && tail != head.succ?
  #   root = fold!(head, tail, MapTag::Nother, dic: 0)

  #   fix_grammar!(head)
  #   root
  # end

  # def fold_quoted!(head : BaseNode) : BaseNode
  #   return head unless char = head.val[0]?
  #   end_tag, end_val = match_end(char)

  #   tail = head
  #   while tail = tail.succ?
  #     # return head if tail.pstop? && !tag.quotecl?
  #     break if tail.tag.tag == end_tag && tail.val[0] == end_val
  #   end

  #   return head unless tail && tail != head.succ?

  #   root = fold!(head, tail, tag: MapTag::Unkn, dic: 0)
  #   fix_grammar!(root.body, level: 1)

  #   succ = head.succ
  #   if succ.succ? == tail
  #     root.dic = 1
  #     root.tag = succ.tag
  #   elsif root.prev? { |x| x.pt_dep? || x.pro_dems? || x.numeral? }
  #     root.tag = MapTag::Nform
  #   end

  #   root.common_nouns? ? fold_nouns!(root, mode: 1) : root
  # end

  # private def match_end(char : Char)
  # end
end
