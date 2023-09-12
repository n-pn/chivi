class MT::MtCpos
  ALL = {
    # base
    "_", # wildcard
    "A", # adjective
    "N", # nominal
    "V", # verbal
    "X", # numbers and units, mathematical sign
    # words
    "AD",  # adverb
    "AS",  # aspect marker
    "BA",  # 把 bǎ in ba-construction
    "CC",  # coordinating conjunction
    "CD",  # cardinal number
    "CS",  # subordinating conjunction
    "DEC", # 的 de as a complementizer or a nominalizer
    "DEG", # 的 de as a genitive marker and an associative marker
    "DER", # 得 resultative de, de in V-de const and V-de-R
    "DEV", # 地 manner de, de before VP
    "DT",  # determiner
    "ETC", # 等, 等等 for words like "etc."
    "EM",  # emoji
    "FW",  # foreign words
    "IJ",  # interjection
    "JJ",  # other noun-modifier
    "LB",  # 被 bèi in long bei-const
    "LC",  # localizer
    "M",   # measure word
    "MSP", # other particle
    "NOI", # noise that characters are written in the wrong order
    "NN",  # common noun
    "NR",  # proper noun
    "NT",  # temporal noun
    "OD",  # ordinal number
    "ON",  # onomatopoeia
    "P",   # preposition e.g., "from" and "to"
    "PN",  # pronoun
    "PU",  # punctuation
    "SB",  # 被 bèi in short bei-const
    "SP",  # sentence final particle
    "URL", # web address
    "VA",  # predicative adjective
    "VC",  # 是 copula, be words
    "VE",  # 有 yǒu as the main verb
    "VV",  # other verb
    # phrases
    "ADJP", # adjective phrase
    "ADVP", # adverbial phrase headed by AD (adverb)
    "CLP",  # classifier phrase
    "CP",   # clause headed by C (complementizer)
    "DNP",  # phrase formed by ‘‘XP + DEG’’
    "DP",   # determiner phrase
    "DVP",  # phrase formed by ‘‘XP + DEV’’
    "FRAG", # fragment
    "INTJ", # interjection
    "IP",   # simple clause headed by I (INFL)
    "LCP",  # phrase formed by ‘‘XP + LC’’
    "LST",  # list marker
    "MSP",  # some particles
    "NN",   # common noun
    "NP",   # noun phrase
    "PP",   # preposition phrase
    "PRN",  # parenthetical
    "QP",   # quantifier phrase
    "TOP",  # root node
    "UCP",  # unidentical coordination phrase
    "VCD",  # coordinated verb compound
    "VCP",  # verb compounds formed by VV + VC
    "VNV",  # verb compounds formed by A-not-A or A-one-A
    "VP",   # verb phrase
    "VPT",  # potential form V-de-R or V-bu-R
    "VRD",  # verb resultative compound
    "VSB",  # verb compounds formed by a modifier + a head
  }

  MAP = Hash(String, Int8).new { |h, k| h[k] = h.size.to_i8 }
  ALL.each_with_index { |cpos, idx| MAP[cpos] = idx.to_i8 }

  PN   = MAP["PN"]
  AS   = MAP["AS"]
  NR   = MAP["NR"]
  NN   = MAP["NN"]
  NP   = MAP["NP"]
  PU   = MAP["PU"]
  EM   = MAP["EM"]
  CD   = MAP["CD"]
  OD   = MAP["OD"]
  M    = MAP["M"]
  P    = MAP["P"]
  VV   = MAP["VV"]
  VP   = MAP["VP"]
  IP   = MAP["IP"]
  CP   = MAP["CP"]
  DP   = MAP["DP"]
  QP   = MAP["QP"]
  PP   = MAP["PP"]
  ADVP = MAP["ADVP"]
  ADJP = MAP["ADJP"]

  # EXTRA TAGS:
  # N: all nouns
  # V: all verbs
  # A: adjective/modifier

  ALT = {
    "VV" => {"V", "_"},
    "VP" => {"V", "_"},
    "VA" => {"A", "_"},
    "JJ" => {"A", "_"},
    "NN" => {"N", "_"},
    "NT" => {"N", "_"},
    "NP" => {"N", "_"},
  }

  def self.[](cpos : String)
    MAP[cpos]
  end

  def self.verb?(ipos : Int8)
    ipos == VV || ipos == VP
  end
end

# To delete:
# "VD" => 66, "DEG2" => 67, "MN" => 68, "MV" => 69, "VM" => 70, "VS" => 71, "MT" => 72, "IC" => 73, "" => 74