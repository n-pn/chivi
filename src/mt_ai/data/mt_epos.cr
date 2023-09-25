enum MT::MtEpos : Int8
  X = 0 # match any

  AD  # adverb
  AS  # aspect marker
  BA  # 把 bǎ in ba-construction
  CC  # coordinating conjunction
  CD  # cardinal number
  CS  # subordinating conjunction
  DEC # 的 de as a complementizer or a nominalizer
  DEG # 的 de as a genitive marker and an associative marker
  DER # 得 resultative de, de in V-de const and V-de-R
  DEV # 地 manner de, de before VP
  DT  # determiner
  ETC # 等, 等等 for words like "etc."
  EM  # emoji
  FW  # foreign words
  IJ  # interjection
  JJ  # other noun-modifier
  LB  # 被 bèi in long bei-const
  LC  # localizer
  M   # measure word
  MSP # other particle
  NOI # noise that characters are written in the wrong order
  NN  # common noun
  NR  # proper noun
  NT  # temporal noun
  OD  # ordinal number
  ON  # onomatopoeia
  P   # preposition e.g., "from" and "to"
  PN  # pronoun
  PU  # punctuation
  SB  # 被 bèi in short bei-const
  SP  # sentence final particle
  URL # web address
  VA  # predicative adjective
  VC  # 是 copula, be words
  VE  # 有 yǒu as the main verb
  VV  # other verb
  # phrases
  ADJP # adjective phrase
  ADVP # adverbial phrase headed by AD (adverb)
  CLP  # classifier phrase
  CP   # clause headed by C (complementizer)
  DNP  # phrase formed by ‘‘XP + DEG’’
  DP   # determiner phrase
  DVP  # phrase formed by ‘‘XP + DEV’’
  FRAG # fragment
  INTJ # interjection
  IP   # simple clause headed by I (INFL)
  LCP  # phrase formed by ‘‘XP + LC’’
  LST  # list marker
  NP   # noun phrase
  PP   # preposition phrase
  PRN  # parenthetical
  QP   # quantifier phrase
  TOP  # root node
  UCP  # unidentical coordination phrase
  VCD  # coordinated verb compound
  VCP  # verb compounds formed by VV + VC
  VNV  # verb compounds formed by A-not-A or A-one-A
  VP   # verb phrase
  VPT  # potential form V-de-R or V-bu-R
  VRD  # verb resultative compound
  VSB  # verb compounds formed by a modifier + a head
  OTH  # other types

  # # additional
  NF # name prefixes
  NH # name suffixes
  NC # center nouns

  @[AlwaysInline]
  def verb?
    self.in?(VA, VC, VE, VV, VCD, VCP, VNV, VP, VPT, VRD, VSB)
  end

  @[AlwaysInline]
  def noun?
    self.in?(NN, NR, NT, NP, NF, NH, NC)
  end

  @[AlwaysInline]
  def is?(epos : self)
    self.value == epos.value
  end
end
