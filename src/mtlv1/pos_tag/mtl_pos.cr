@[Flags]
enum CV::MtlPos : UInt64
  Boundary # make structure boundary

  # rendering
  CapAfter
  NoSpaceR

  # placement

  AdvPre # adverb phrase put before center verb
  AdvSuf # adverb phrase put after center verb

  ModPre # modifier stays before center noun
  ModSub # modifier stays after center noun

  Ktetic # possessive determiner
  # demonstrative determiner

  Redup # reduplication

  # context

  Person # all words that refer to human beings
  Locale # all words that can be placement

  # # groups

  Nounish # word can act as noun
  Verbish # word can act as verb
  Adjtish # word can act as adjective

  # specific

  LinkVerb # can link verbs

  JoinWord # can be use to link two words/two phraes

  CanSplit # can split to other structure
end

struct CV::PosTag
  getter pos = MtlPos::None

  delegate boundary?, to: @pos

  delegate cap_after?, to: @pos
  delegate no_space_l?, to: @pos
  delegate no_space_r?, to: @pos

  delegate adv_pre?, to: @pos
  delegate adv_suf?, to: @pos

  delegate mod_pre?, to: @pos
  delegate mod_suf?, to: @pos

  delegate ktetic?, to: @pos
  delegate redup?, to: @pos

  delegate person?, to: @pos
  delegate locale?, to: @pos

  delegate nounish?, to: @pos
  delegate verbish?, to: @pos
  delegate adjtish?, to: @pos

  delegate link_verb?, to: @pos
  delegate join_word?, to: @pos
  delegate can_split?, to: @pos
end
