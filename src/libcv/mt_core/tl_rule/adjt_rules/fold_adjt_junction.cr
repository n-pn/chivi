module CV::TlRule
  def fold_adjt_junction!(junc : MtNode, prev = junc.prev, succ = junc.succ?)
    return if !succ || succ.ends?

    succ = fold_once!(succ)
    return unless succ.adjective?

    fold!(prev, succ, tag: PosTag::AdjtPhrase, dic: 4)
  end
end
