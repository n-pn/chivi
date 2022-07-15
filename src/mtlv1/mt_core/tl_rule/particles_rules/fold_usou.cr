module CV::TlRule
  def fold_usuo!(usuo : MtNode, succ = usuo.succ?)
    return usuo unless succ

    succ = heal_mixed!(succ) if succ.mixed?
    return usuo unless succ.verbal?

    usuo.val = "chỗ"
    verb = fold!(usuo, succ, succ.tag, dic: 6)
    fold_verbs!(verb)
  end
end
