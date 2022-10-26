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
  BindWord # can be use to link two words/two phraes

  MaybeModi # word can act as noun modifier
  MaybeAdvb # word can act as adverb

  # verb flags

  MaybeAuxi # can be verb auxiliary
  MaybeCmpl # can be verb complement

  Volitive # verb predicate expression a desire to do something
  Vlinking # can link verbs

  HasAspect # has aspect marker
  HasDircom # has directional complement
  HasRescom # has result complement

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
  delegate bind_word?, to: @pos

  delegate maybe_modi?, to: @pos
  delegate maybe_advb?, to: @pos

  delegate maybe_auxi?, to: @pos
  delegate maybe_cmpl?, to: @pos

  delegate volitive?, to: @pos
  delegate vlinking?, to: @pos
end
