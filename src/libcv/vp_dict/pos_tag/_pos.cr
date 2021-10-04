struct CV::PosTag
  @[Flags]
  enum Pos
    # content words - functional words - punctuations
    Contws; Funcws; Puncts

    Nouns; Pronouns
    Names; Human

    Verbs; Adjts

    Numbers; Quantis; Strings

    Auxils; Preposes

    Suffixes

    Uniqs
  end
end
