struct CV::MtlV2::PosTag
  @[Flags]
  enum Pos
    # content words - functional words - punctuations
    Contws; Funcws
    Puncts; Pstops; Popens

    Nominal; Names; Human; Object

    Pronouns; ProDems; ProInts

    Verbal; V0Obj

    Vmodals

    Adjective; Modifier

    Adverbial

    Numbers; Quantis; Nquants; Numeral

    Auxils; Preposes
    Strings

    Junction
    # Terminal # mark open or end of a sentence

    Measure # adjt/verb that can combine with numbers

    Suffixes # all kind of suffixes

    Mixed; Special
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
  delegate v0_obj?, to: @pos

  delegate vmodals?, to: @pos

  delegate modifier?, to: @pos
  delegate adjective?, to: @pos
  delegate adverbial?, to: @pos

  delegate preposes?, to: @pos
  delegate auxils?, to: @pos

  delegate junction?, to: @pos
  delegate terminal?, to: @pos

  delegate measure?, to: @pos
  delegate strings?, to: @pos

  delegate contws?, to: @pos
  delegate special?, to: @pos

  delegate suffixes?, to: @pos

  @[Flags]
  enum Sub
    # verb subtypes
    V2Object; VDircomp; VCombine; VCompare; VLinking
  end

  delegate v2_object?, to: @sub
  delegate v_dircomp?, to: @sub
  delegate v_combine?, to: @sub
  delegate v_compare?, to: @sub
  delegate v_linking?, to: @sub
end
