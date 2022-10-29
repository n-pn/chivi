@[Flags]
enum MT::MtlPos : UInt64
  def self.parse(values : Array(String), init : MtlPos = :none)
    values.reduce(init) { |flags, value| flags | parse(value) }
  end

  # rendering

  Boundary # make structure boundary
  CapAfter # add capitalizion after this node
  CapRelay # relay capitalization
  Skipover # for word that marked empty

  NoSpaceR
  NoSpaceL

  AtHead
  AtTail

  ###

  Peculiar # word has special meaning
  Mixedpos # word has multi roles

  Unreal # not a content word
  Ktetic # possessive determiner
  Object # act as object complement for verb

  # chararistic

  # Plural # plural nouns/pronouns

  Humankind # all words that refer to human beings
  Placeword # all words that can be place or location

  ToCompare # verb or prepos using in comparision
  ToMeasure # verb or adjective using in measurement

  # part in speech

  CanSplit # can split to other structure
  JoinWord # can be use to link two words/two phraes

  # mixed post

  MaybeNoun # words can act as noun
  MaybeVerb # words can act as verb

  MaybeAdjt # words can act as adjective
  MaybeModi # words can act as modifier

  MaybePrep # words can act as preposition
  MaybeConj # words can act as conjunction

  MaybeAdvb # words can act as adverb
  MaybeAuxi # words can act as verb auxiliary
  MaybeCmpl # words can act as verb complement

  MaybeQuanti # words can act as quantifier
  MaybeNquant # words can act as number + quanti form

  # verb form

  Volitive # verb predicate expression a desire to do something
  Vlinking # can link verbs

  HasAspcmpl # has aspect marker
  HasDircmpl # has directional complement
  HasRescmpl # has result complement

  # grammar
  CanBeSubj # can be subject
  CanBePred # can be predicate
end

module MT::HasPos
  property pos = MtlPos::None

  delegate boundary?, to: @pos
  delegate skipover?, to: @pos

  delegate cap_after?, to: @pos
  delegate cap_repay?, to: @pos

  delegate no_space_l?, to: @pos
  delegate no_space_r?, to: @pos

  delegate at_head?, to: @pos
  delegate at_tail?, to: @pos

  delegate peculiar?, to: @pos
  delegate mixedpos?, to: @pos

  delegate unreal?, to: @pos
  delegate ktetic?, to: @pos
  delegate object?, to: @pos

  delegate humankind?, to: @pos
  delegate placeword?, to: @pos

  delegate to_compare?, to: @pos
  delegate to_measure?, to: @pos

  delegate can_split?, to: @pos
  delegate join_word?, to: @pos

  delegate maybe_noun?, to: @pos
  delegate maybe_verb?, to: @pos

  delegate maybe_adjt?, to: @pos
  delegate maybe_modi?, to: @pos

  delegate maybe_prep?, to: @pos
  delegate maybe_conj?, to: @pos

  delegate maybe_advb?, to: @pos

  delegate maybe_auxi?, to: @pos
  delegate maybe_cmpl?, to: @pos

  delegate maybe_quanti?, to: @pos
  delegate maybe_nquant?, to: @pos

  delegate volitive?, to: @pos
  delegate vlinking?, to: @pos

  delegate has_aspcmpl?, to: @pos
  delegate has_dircmpl?, to: @pos
  delegate has_rescmpl?, to: @pos
end
