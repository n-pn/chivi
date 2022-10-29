module MT::Rules
  def fold_pronoun!(pronoun : MtNode)
    # FIXME: combine pronouns

    foldl_objt_full!(objt: pronoun)
  end
end
