module MT::Core
  def fold_pronoun!(pronoun : MtNode)
    # FIXME: combine pronouns

    fold_objt_left!(objt: pronoun)
  end
end
