module CV::TlRule
  def fold_noun_after!(noun : MtNode, succ = noun.succ?) : MtNode
    return noun unless succ
    noun = fold_uzhi!(uzhi: succ, prev: noun) if succ.uzhi?
    fold_noun_space!(noun: noun)
  end
end
