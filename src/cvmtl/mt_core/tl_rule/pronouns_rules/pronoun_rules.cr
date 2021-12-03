module CV::TlRule
  def fold_pronouns!(pronoun : MtNode, succ = pronoun.succ?) : MtNode
    return pronoun unless succ

    case pronoun.tag
    when .pro_per?  then fold_pro_per!(pronoun, succ)
    when .pro_dems? then fold_pro_dems!(pronoun, succ)
    else                 pronoun
    end
  end
end
