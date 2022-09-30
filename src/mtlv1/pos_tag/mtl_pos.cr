@[Flags]
enum CV::MtlPos : UInt64
  # rendering
  CapAfter
  NoSpaceL
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

  Names   # proper nouns
  Nouns   # common nouns
  Nominal # all nouns
  Nounish # word can act as noun

  Verbs   # all regular verb
  Verbal  # regular verb + special verbs
  Verbish # word can act as verb

  Adjts   # all regular adjt
  Adjtval # adjectival, word can act as adjective

  ###

  Polysemy # words that have multi meaning/part-of-speech
  Singular # special words that need to be check before build semantic tree
  Nebulous # words need to be fix (including singular and polysemy)
end

struct CV::PosTag
  getter pos = MtlPos::None

  delegate cap_after?, to: @pos
  delegate no_space_l?, to: @pos
  delegate no_space_r?, to: @pos

  delegate adv_pre?, to: @pos
  delegate adv_suf?, to: @pos

  delegate mod_pre?, to: @pos
  delegate mod_suf?, to: @pos

  delegate ktetic?, to: @pos
end
