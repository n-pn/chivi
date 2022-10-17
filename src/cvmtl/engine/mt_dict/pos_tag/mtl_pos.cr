@[Flags]
enum MT::MtlPos : UInt64
  def self.parse(values : Array(String), init : MtlPos = :none)
    values.reduce(init) { |flags, value| flags | parse(value) }
  end

  Passive # for word that marked empty

  Boundary # make structure boundary
  Mixedpos # word not tagged

  # rendering

  CapAfter # add capitalizion after this node
  CapRelay # relay capitalization

  NoSpaceR
  NoSpaceL

  AtHead
  AtTail

  # charisteric

  Redup # reduplication

  # placement

  Ktetic # possessive determiner
  Object # act as object complement for verb

  Aspect # aspect marker
  Vauxil # put before verb
  Vcompl # verb complement

  # chararistic

  Proper # proper nouns
  Plural # plural nouns/pronouns
  People # all words that refer to human beings
  Locale # all words that can be placement
  Desire # verb predicate expression a desire to do something

  Compare # verb or prepos using in comparision
  Measure # verb or adjective using in measurement

  # part in speech

  MaybeNoun # word can act as noun
  MaybeVerb # word can act as verb
  MaybeAdjt # word can act as adjective
  MaybeAdvb # word can act as adverb

  Modifier # word can act as noun direct modifier
  LinkVerb # can link verbs
  CanSplit # can split to other structure
  BondWord # can be use to link two words/two phraes

  # complements
  HasAsmCom # has aspect marker
  HasDirCom # has directional complement
  HasResCom # has result complement
end