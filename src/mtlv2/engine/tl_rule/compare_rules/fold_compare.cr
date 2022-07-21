module MtlV2::TlRule
  def fold_compare(head : BaseNode, tail = head.succ?)
    while tail
      return if tail.puncts? || tail.key == "像"

      if tail.uyy?
        break unless tail.key == "一样" || tail.key == "不一样"
        break unless tail.succ?(&.ude1?)
      end

      tail = tail.succ?
    end

    return unless tail && tail != head.succ?

    MtDict.v_compare.get_val(head.key).try { |x| head.val = x }

    case tail.key
    when "一样", "似的", "一般", "般" then tail.val = "như"
    when "不一样"                 then tail.val = "không giống"
    end

    fold_list!(head, tail)
    root = fold!(head, tail, tag: PosTag::AdjtPhrase, dic: 0)
    tail.prev.fix_succ!(nil)
    tail.fix_succ!(head.succ?)
    head.fix_succ!(tail)

    return root unless succ = scan_adjt!(root.succ?)
    return root unless succ.adjective? || succ.verb_object?

    fold!(root, succ, PosTag::Aform, dic: 1, flip: true)
  end

  def fold_compare_prepos(head : BaseNode, tail = head.succ?)
    while tail
      return if tail.puncts?

      if tail.key.in?("相同", "一样")
        tail.succ?(&.ude1?) ? return : break
      end

      tail = tail.succ?
    end

    return unless tail && tail != head.succ?

    # puts [head, tail]
    prev = tail.prev

    head.val = "với"
    tail.val = "giống"

    if prev.key == "不"
      tail = fold!(prev, tail, tail.tag, dic: 1)
      prev = tail.prev
    end

    if prev.key == "完全" || prev.adverbial?
      prev = MtDict.fix_adverb!(prev)
      tail = fold!(prev, tail, tail.tag, dic: 1)
      prev = tail.prev
    end

    # noun = fold!(head.succ, prev, PosTag::Noun, dic: 3)
    prep = fold!(head, prev, PosTag::PrepClause, dic: 7)
    fix_grammar!(prep.body)

    node = fold!(prep, tail, PosTag::AdjtPhrase, dic: 8, flip: true)

    return node unless succ = scan_adjt!(node.succ?)
    return node unless succ.adjective? || succ.verb_object?

    head.val = "như"
    tail.val = ""
    fold!(node, succ, PosTag::AdjtPhrase, dic: 1, flip: true)
  end
end
