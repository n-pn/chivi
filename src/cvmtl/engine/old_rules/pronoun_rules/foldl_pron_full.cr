module MT::Rules
  def foldl_pron_full!(pronoun : MtNode)
    # FIXME: combine pronouns

    foldl_objt_full!(objt: pronoun)
  end
end
