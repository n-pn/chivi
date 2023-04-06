enum MT::BasicNER::EntityType
  DigNumber # digit number
  HanNumber # hanzi number

  Quantifier # number + measure word/classifiers

  TimeLiteral # 12:32 or 12:32:32
  DateLiteral # 2022/12/23 or 2001-09-11

  TimePhrase # combine time with other words
  DatePhrase # combine date with other words

  MathLiteral # math expression
  LinkLiteral # weblink

  ForeignWord # latin only tokens
  ForeignName # latin only tokens with capitalized characters

  UnknLiteral # other kind of literals
end
