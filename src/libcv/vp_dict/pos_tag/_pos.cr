struct CV::PosTag
  @[Flags]
  enum Pos
    # content words - functional words - punctuations
    Contws; Funcws; Puncts

    Nouns; Names; Pronouns
    Verbs; Adjts

    Numbers; Quantis; Strings

    Auxils; Preposes

    Prefixes; Suffixes

    Uniqs
  end
end
