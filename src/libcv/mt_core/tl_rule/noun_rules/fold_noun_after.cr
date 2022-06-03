module CV::TlRule
  def fold_noun_after!(noun : MtNode, succ = noun.succ?) : MtNode
    return noun unless succ

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

    succ.junction? ? fold_noun_concoord!(succ, prev: noun) || noun : noun
  end
end
