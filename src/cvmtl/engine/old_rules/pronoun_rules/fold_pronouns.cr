module MT::TlRule
  def fold_pronouns!(pronoun : MtNode, succ = pronoun.succ?) : MtNode
    return pronoun unless succ

    case pronoun.tag
    when .per_prons? then fold_pro_per!(pronoun, succ)
      # when .pro_na2?  then fold_pro_dems!(pronoun, succ)
      # when .dem_prons? then fold_pro_dems!(pronoun, succ)
    when .pro_ints? then fold_pro_ints!(pronoun, succ)
    else                 pronoun
    end
  end
end
