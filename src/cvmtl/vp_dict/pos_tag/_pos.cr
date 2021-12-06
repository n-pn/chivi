struct CV::PosTag
  @[Flags]
  enum Pos
    # content words - functional words - punctuations
    Contws; Funcws; Puncts; Pstops; Popens

    Nouns; Times; Names; Human; Object

    Pronouns; ProDems; ProInts

    Verbs; Vdirs; Vmodals
    Adjts; Adverbs

    Numbers; Quantis; Nquants; Numeric

    Auxils; Preposes
    Strings; Uniques
  end
end
