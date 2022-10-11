module MT::TlRule
  def fold_noun_after!(noun : BaseNode, succ = noun.succ?) : BaseNode
    return noun unless succ

    if succ.pro_ziji?
      noun = fold!(noun, succ, noun.tag, flip: true)
      return noun unless succ = noun.succ?
    end

    noun = fold_uzhi!(uzhi: succ, prev: noun) if succ.pt_zhi?
    noun = fold_noun_space!(noun: noun)

    return noun unless (succ = noun.succ?) && succ.bond_word?
    fold_noun_concoord!(succ, prev: noun) || noun
  end
end
