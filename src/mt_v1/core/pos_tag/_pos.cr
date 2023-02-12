struct M1::PosTag
  @[Flags]
  enum Pos : UInt64
    # content words - functional words - punctuations
    Puncts; Pstops; Popens

    Polysemy

    Nominal; Names; Human

    Pronouns; ProDems; ProInts

    Verbal; Vdirs; Vmodals
    Adjective; Adverbial

    Numbers; Quantis; Nquants; Numeral

    Preposes
    Strings; Specials; Suffixes
  end

  delegate polysemy?, to: @pos
  delegate nominal?, to: @pos

  delegate names?, to: @pos
  delegate human?, to: @pos

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

  delegate specials?, to: @pos
  delegate suffixes?, to: @pos
  delegate strings?, to: @pos
end
