module CV::TlRule
  def fold_v_shi!(vshi : MtNode, succ = vshi.succ?)
    return vshi unless succ

    succ = scan_noun!(succ)
    return vshi unless succ && (tail = succ.succ?) && succ.subject?

    tail = fold_verbs!(tail) if tail.verbs?
    fold!(succ, tail, PosTag::VerbClause, dic: 7) if tail.verbs? && tail.succ?(&.ude1?)

    vshi
  end
end
