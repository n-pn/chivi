struct CV::PosTag
  @[Flags]
  enum Pos
    # content words - functional words - punctuations
    Contws; Funcws
    Puncts; Pstops; Popens

    Mixed

    Nominal; Times; Names; Human; Object

    Pronouns; ProDems; ProInts

    Verbal; Vdirs; Vmodals
    Adjective; Adverbial

    Numbers; Quantis; Nquants; Numeral

    Auxils; Preposes
    Strings; Specials
  end

  delegate mixed?, to: @pos

  delegate nominal?, to: @pos

  delegate times?, to: @pos
  delegate names?, to: @pos
  delegate human?, to: @pos
  delegate object?, to: @pos

  delegate numbers?, to: @pos
  delegate quantis?, to: @pos
  delegate nquants?, to: @pos
  delegate numeral?, to: @pos

  delegate pronouns?, to: @pos
  delegate pro_dems?, to: @pos
  delegate pro_ints?, to: @pos

  delegate verbal?, to: @pos
  delegate vdirs?, to: @pos
  delegate vmodals?, to: @pos

  delegate adjective?, to: @pos
  delegate adverbial?, to: @pos

  delegate preposes?, to: @pos
  delegate auxils?, to: @pos

  delegate junction?, to: @pos
  delegate strings?, to: @pos

  delegate contws?, to: @pos
  delegate specials?, to: @pos
end
