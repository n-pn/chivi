module CV::TlRule
  def fold_noun_after!(noun : MtNode, succ = noun.succ?) : MtNode
    return noun unless succ

    noun = fold_uzhi!(uzhi: succ, prev: noun) if succ.uzhi?
    noun = fold_noun_space!(noun: noun)

    return noun unless (succ = noun.succ?) && succ.junction?
    fold_noun_concoord!(succ, prev: noun) || noun
  end
end
