struct CV::PosTag
  SOUND_MAP    = load_map("var/cvmtl/postag/sounds.tsv")
  ADVERB_MAP   = load_map("src/cvmtl/mapping/adverbs.tsv")
  CONJUNCT_MAP = load_map("src/cvmtl/mapping/conjunts.tsv")

  def map_sound(key : String)
    SOUND_MAP[key] || new(:onomat)
  end

  def map_adverb(key : String)
    ADVERB_MAP[key] || new(:adv_term)
  end

  def map_conjunt(key : String)
    CONJUNCT_MAP[key] || new(:conjunct)
  end
end
