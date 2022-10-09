module MT::TlRule
  def fold_usuo!(usuo : BaseNode, succ = usuo.succ?)
    return usuo unless succ

    succ = heal_mixed!(succ) if succ.polysemy?
    return usuo unless succ.verb_words?

    usuo.val = "chỗ"
    verb = fold!(usuo, succ, succ.tag, dic: 6)
    fold_verbs!(verb)
  end
end
