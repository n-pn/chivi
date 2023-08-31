module MT::MapPos
  extend self

  UD_TO_CTB = {
    "RB"   => "AD", # adverb
    "NNP"  => "NR", # proper noun
    "UH"   => "SP", # sentence final particle
    "NNB"  => "M",  # quantifier
    "VERB" => "VV",
    "MD"   => "VM", # modal verb

    "PNR" => "PN", # personal pronoun
    "PND" => "PN", # demonstrative pronoun
    "WP"  => "PN", # interrogative pronoun
  }

  def ud_to_ctb(xpos : String, upos : String = "", feat = "")
    # TODO:
    # - convert number to OD or CD depends on feat
    # - convert punctuations to PU
    # - convert BB to SB and LB
    UD_TO_CTB.fetch(xpos, xpos)
  end
end
