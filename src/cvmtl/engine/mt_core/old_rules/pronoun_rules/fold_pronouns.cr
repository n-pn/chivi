module MT::TlRule
  def fold_pronouns!(pronoun : BaseNode, succ = pronoun.succ?) : BaseNode
    return pronoun unless succ

    case pronoun.tag
    when .pro_pers? then fold_pro_per!(pronoun, succ)
      # when .pro_na2?  then fold_pro_dems!(pronoun, succ)
      # when .pro_dems? then fold_pro_dems!(pronoun, succ)
    when .pro_ints? then fold_pro_ints!(pronoun, succ)
    else                 pronoun
    end
  end
end
