require "./mtl_tag"

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

  MaybeMod # word can act as noun modifier
  MaybeAdv # word can act as adverb

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
