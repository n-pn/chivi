struct CV::PosTag
  @[Flags]
  enum Pos
    # content words - functional words - punctuations
    Contws; Funcws; Puncts; Endsts; Starts

    Nouns; Names; Human; Pronouns
    Verbs; Vmodals; Adjts; Adverbs

    Numbers; Quantis; Strings

    Auxils; Preposes

    SufNouns; SufVerbs; SufAdjts

    Uniqs
  end
end
