@[Flags]
enum CV::MtlPos : UInt64
  def self.parse(values : Array(String), init : self = :none)
    values.reduce(init) { |flags, value| flags | parse(value) }
  end

  Boundary # make structure boundary

  # rendering

  CapAfter
  NoWsAfter
  NoWsBefore

  AtHead
  AtTail

  # charisteric

  Redup # reduplication

  # placement

  Ktetic # possessive determiner

  Aspect # aspect marker
  Vauxil # put before verb

  Vcompl # verb complement
  Object # act as object complement for verb

  # chararistic

  Proper # proper nouns

  Plural # plural nouns/pronouns
  People # all words that refer to human beings
  Locale # all words that can be placement

  # part in speech

  Nounish # word can act as noun
  Verbish # word can act as verb
  Adjtish # word can act as adjective
  Advbial # advbial, word can act as adverb

  # specific

  LinkVerb # can link verbs
  JoinWord # can be use to link two words/two phraes
  CanSplit # can split to other structure

  # complements
  HasAsmCom # has aspect marker
  HasDirCom # has directional complement
  HasResCom # has result complement
end

struct CV::PosTag
  delegate boundary?, to: @pos

  delegate cap_after?, to: @pos
  delegate no_ws_before?, to: @pos
  delegate no_ws_after?, to: @pos

  delegate at_head?, to: @pos
  delegate at_tail?, to: @pos

  delegate redup?, to: @pos

  delegate ktetic?, to: @pos
  delegate aspect?, to: @pos
  delegate vcompl?, to: @pos
  delegate object?, to: @pos

  delegate proper?, to: @pos
  delegate plural?, to: @pos
  delegate people?, to: @pos
  delegate locale?, to: @pos

  delegate nounish?, to: @pos
  delegate verbish?, to: @pos
  delegate adjtish?, to: @pos
  delegate advbial?, to: @pos

  delegate link_verb?, to: @pos
  delegate join_word?, to: @pos
  delegate can_split?, to: @pos
end
