@[Flags]
enum CV::MtlPos : UInt64
  def self.parse(values : Array(String), init : self = :none)
    values.reduce(init) { |flags, value| flags | parse(value) }
  end

  Boundary # make structure boundary
  Overlook # for word that marked empty
  Nebulous # word not tagged

  # rendering

  CapAfter # add capitalizion after this node
  CapRelay # relay capitalization

  NoWsAfter
  NoWsBefore

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

  # part in speech

  MaybeNoun # word can act as noun
  MaybeVerb # word can act as verb
  MaybeAdjt # word can act as adjective
  MaybeAdvb # word can act as adverb

  Modifier # word can act as noun direct modifier
  LinkVerb # can link verbs
  CanSplit # can split to other structure

  BondWord # can be use to link two words/two phraes
  BondVerb # links two verbs
  BondAdjt # links tow adjts
  BondNoun # links two nouns

  # complements
  HasAsmCom # has aspect marker
  HasDirCom # has directional complement
  HasResCom # has result complement
end

struct CV::PosTag
  def nebulous?
    @pos.nebulous? || @tag.nebulous?
  end

  delegate boundary?, to: @pos
  delegate inactive?, to: @pos

  delegate cap_after?, to: @pos
  delegate no_ws_before?, to: @pos
  delegate no_ws_after?, to: @pos

  delegate at_head?, to: @pos
  delegate at_tail?, to: @pos

  delegate redup?, to: @pos

  delegate aspect?, to: @pos
  delegate vauxil?, to: @pos

  delegate ktetic?, to: @pos
  delegate aspect?, to: @pos
  delegate vcompl?, to: @pos
  delegate object?, to: @pos

  delegate proper?, to: @pos
  delegate plural?, to: @pos
  delegate people?, to: @pos
  delegate locale?, to: @pos

  delegate maybe_noun?, to: @pos
  delegate maybe_verb?, to: @pos
  delegate maybe_adjt?, to: @pos
  delegate maybe_advb?, to: @pos

  delegate can_split?, to: @pos
  delegate link_verb?, to: @pos

  delegate bond_word?, to: @pos
  delegate bond_noun?, to: @pos
  delegate bond_verb?, to: @pos
  delegate bond_adjt?, to: @pos
end
