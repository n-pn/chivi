module M1::TlRule
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

  def fold_nested!(head : MtNode, tail : MtNode)
    fold_list!(head, tail)
    ptag = guess_nested_tag(head, tail)
    list = fold!(head, tail, tag: ptag, dic: 0)
    # list.inspect
    list
  end

  def guess_nested_tag(head : MtNode, tail : MtNode)
    case head.tag
    when .titleop? then PosTag::Btitle
    when .brackop? then PosTag::Nother
    when .parenop? then PosTag::ParenExpr
    else                guess_quoted_tag(head, tail)
    end
  end

  def guess_quoted_tag(head : MtNode, tail : MtNode)
    head_succ = head.succ
    tail_prev = tail.prev

    if head_succ == tail_prev
      return head_succ.tag unless head_succ.tag.polysemy?
      return heal_mixed!(head_succ, head.prev?, tail.succ?).tag
    end

    if (tail_prev.exmark? || tail_prev.ude1?) &&
       (head_succ.onomat? || head_succ.exclam?) &&
       (head.prev?(&.ends?.!) || tail.succ?(&.ude1?))
      return head_succ.tag
    end

    head.prev?(&.ude1?) ? PosTag::NounPhrase : PosTag::Unkn
  end

  # def fold_btitle!(head : MtNode) : MtNode
  #   return head unless start_key = head.key[0]?
  #   end_key = match_title_end(start_key)

  #   tail = head

  #   while tail = tail.succ?
  #     break if tail.titlecl? && tail.key[0]? == end_key
  #   end

  #   return head unless tail && tail != head.succ?
  #   root = fold!(head, tail, PosTag::Nother, dic: 0)

  #   fix_grammar!(head)
  #   root
  # end

  # def fold_quoted!(head : MtNode) : MtNode
  #   return head unless char = head.val[0]?
  #   end_tag, end_val = match_end(char)

  #   tail = head
  #   while tail = tail.succ?
  #     # return head if tail.pstop? && !tag.quotecl?
  #     break if tail.tag.tag == end_tag && tail.val[0] == end_val
  #   end

  #   return head unless tail && tail != head.succ?

  #   root = fold!(head, tail, tag: PosTag::Unkn, dic: 0)
  #   fix_grammar!(root.body, level: 1)

  #   succ = head.succ
  #   if succ.succ? == tail
  #     root.dic = 1
  #     root.tag = succ.tag
  #   elsif root.prev? { |x| x.ude1? || x.pro_dems? || x.numeral? }
  #     root.tag = PosTag::NounPhrase
  #   end

  #   root.noun? ? fold_nouns!(root, mode: 1) : root
  # end

  # private def match_end(char : Char)
  # end
end
