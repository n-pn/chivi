struct CV::PosTag
  @[Flags]
  enum Pos
    # content words - functional words - punctuations
    Contws; Funcws; Puncts; Endsts

    Nouns; Pronouns
    Names; Human

    Verbs; Vmodals

    Adjts; Adverbs

    Numbers; Quantis; Strings

    Auxils; Preposes

    Suffixes

    Uniqs
  end
end
