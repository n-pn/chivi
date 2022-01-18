module CV::TlRule
  def fold_v_shi!(vshi : MtNode, succ = vshi.succ?)
    return vshi unless succ

    succ = scan_noun!(succ)
    return vshi unless succ && (tail = succ.succ?) && succ.subject?

    tail = fold_verbs!(tail) if tail.verbs?
    if tail.verbs? && tail.succ?(&.ude1?)
      tag = succ.verb_object? ? tail.tag : PosTag::VerbClause
      fold!(succ, tail, tag: tag, dic: 8)
    end

    vshi
  end
end
