struct CV::PosTag
  @[Flags]
  enum Pos
    # content words - functional words - punctuations
    Contws; Funcws; Puncts

    Nouns; Verbs; Adjts; Pronouns

    Numbers; Quantis; Strings

    Auxils; Preposes

    Uniqs
  end
end
