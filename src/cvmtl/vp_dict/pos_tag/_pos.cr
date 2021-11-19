struct CV::PosTag
  @[Flags]
  enum Pos
    # content words - functional words - punctuations
    Contws; Funcws; Puncts; Pstops; Popens; Starts

    Nouns; Names; Human

    Pronouns; ProDems; ProInts

    Verbs; Vdirs; Vmodals

    Adjts; Adverbs

    Numbers; Quantis; Nquants; Numeric

    Auxils; Preposes

    SufNouns; SufVerbs; SufAdjts

    Strings; Uniques
  end
end
