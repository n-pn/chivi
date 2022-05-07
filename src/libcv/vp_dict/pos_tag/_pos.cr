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
    Strings; Specials
  end

  delegate nouns?, to: @pos
  delegate times?, to: @pos
  delegate names?, to: @pos
  delegate human?, to: @pos
  delegate object?, to: @pos

  delegate numbers?, to: @pos
  delegate quantis?, to: @pos
  delegate nquants?, to: @pos
  delegate numeric?, to: @pos

  delegate pronouns?, to: @pos
  delegate pro_dems?, to: @pos
  delegate pro_ints?, to: @pos

  delegate verbs?, to: @pos
  delegate vdirs?, to: @pos
  delegate vmodals?, to: @pos

  delegate adjts?, to: @pos
  delegate adverbs?, to: @pos

  delegate preposes?, to: @pos
  delegate auxils?, to: @pos

  delegate junction?, to: @pos
  delegate strings?, to: @pos

  delegate contws?, to: @pos
  delegate funcws?, to: @pos
  delegate specials?, to: @pos
end
