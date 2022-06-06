module CV::TlRule
  def fold_noun_after!(noun : MtNode, succ = noun.succ?) : MtNode
    return noun if !succ || succ.ends?

    if succ.pro_per? && succ.key == "自己"
      noun = fold!(noun, succ, noun.tag, dic: 6, flip: true)
      return noun unless succ = noun.succ?
    end

    if succ.uzhi?
      noun = fold_uzhi!(uzhi: succ, prev: noun)
      return noun unless succ = noun.succ?
    end

    if succ.locality?
      noun = fold_noun_locality!(noun: noun, locality: succ)
      return noun unless succ = noun.succ?
    end

    if succ.junction?
      return noun unless fold = fold_noun_junction!(succ, prev: noun)
      noun = fold
    end

    return noun unless (ude1 = noun.succ?) && ude1.ude1?
    fold_ude1!(ude1: ude1, left: noun)
  end
end
