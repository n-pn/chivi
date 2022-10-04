module CV::TlRule
  def fold_v_shi!(vshi : MtNode, succ = vshi.succ?)
    # puts [vshi, succ]
    return vshi unless (succ = scan_noun!(succ)) && (tail = succ.succ?)

    tail = fold_verbs!(tail) if tail.verbal?
    if tail.verbal? && tail.succ?(&.pd_dep?)
      tag = succ.verb_object? ? tail.tag : PosTag::VerbClause
      fold!(succ, tail, tag: tag, dic: 8)
    end

    vshi
  end
end
