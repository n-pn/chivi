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

  AdvPre # adverb phrase put before center verb
  AdvSuf # adverb phrase put after center verb

  ModPre # modifier stays before center noun
  ModSub # modifier stays after center noun

  Ktetic # possessive determiner

  Aspect # aspect marker
  Vauxil # put before verb

  Vcompl # verb complement
  Object # act as object complement for verb

  # context

  Proper # proper nouns
  People # all words that refer to human beings
  Locale # all words that can be placement

  # # groups

  Nounish # word can act as noun
  Verbish # word can act as verb
  Adjtish # word can act as adjective
  Advbial # adverbial

  # specific

  LinkVerb # can link verbs

  JoinWord # can be use to link two words/two phraes

  CanSplit # can split to other structure
end

struct CV::PosTag
  delegate boundary?, to: @pos

  delegate cap_after?, to: @pos
  delegate no_ws_before?, to: @pos
  delegate no_ws_after?, to: @pos

  delegate at_head?, to: @pos
  delegate at_tail?, to: @pos

  delegate redup?, to: @pos

  delegate adv_pre?, to: @pos
  delegate adv_suf?, to: @pos

  delegate mod_pre?, to: @pos
  delegate mod_suf?, to: @pos

  delegate ktetic?, to: @pos
  delegate aspect?, to: @pos
  delegate vcompl?, to: @pos
  delegate object?, to: @pos

  delegate proper?, to: @pos
  delegate person?, to: @pos
  delegate locale?, to: @pos

  delegate nounish?, to: @pos
  delegate verbish?, to: @pos
  delegate adjtish?, to: @pos

  delegate link_verb?, to: @pos
  delegate join_word?, to: @pos
  delegate can_split?, to: @pos
end
