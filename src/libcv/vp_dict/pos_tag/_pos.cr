struct CV::PosTag
  @[Flags]
  enum Pos
    # content words - functional words - punctuations
    Contws; Funcws; Puncts; Pstops; Popens; Starts

    Nouns; Names; Human

    Pronouns; ProDems; ProInts

    Verbs; Vmodals; Vcompls

    Adjts; Adverbs

    Numbers; Quantis; Nquants; Strings

    Auxils; Preposes

    SufNouns; SufVerbs; SufAdjts

    Uniqs
  end
end
