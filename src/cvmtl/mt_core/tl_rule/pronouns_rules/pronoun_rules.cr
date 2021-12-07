module CV::TlRule
  def fold_pronouns!(pronoun : MtNode, succ = pronoun.succ?) : MtNode
    return pronoun unless succ

    case pronoun.tag
    when .pro_per?  then fold_pro_per!(pronoun, succ)
    when .pro_dems? then fold_pro_dems!(pronoun, succ)
    when .pro_ints? then fold_proints!(pronoun, succ)
    else                 pronoun
    end
  end

  def fold_proints!(proint : MtNode, succ : MtNode)
    case succ
    when .nouns?
      succ = scan_noun!(succ)
    when .verbs?
      succ = fold_verbs!(succ)
    else
      return proint
    end

    flip = false

    case proint.key
    when "什么"
      proint.set!("gì")
      flip = true
    end

    fold!(proint, succ, succ.tag, dic: 3, flip: flip)
  end
end
