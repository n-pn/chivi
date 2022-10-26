module MT::TlRule
  def fold_usuo!(usuo : MtNode, succ = usuo.succ?)
    return usuo unless succ

    succ = heal_mixed!(succ) if succ.polysemy?
    return usuo unless succ.verbal_words?

    usuo.val = "chỗ"
    verb = fold!(usuo, succ, succ.tag)
    fold_verbs!(verb)
  end
end
