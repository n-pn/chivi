struct CV::PosTag
  SOUND_MAP    = load_map("sounds")
  ADVERB_MAP   = load_map("adverbs")
  CONJUNCT_MAP = load_map("conjunts")

  def self.map_sound(key : String)
    SOUND_MAP[key] || new(:onomat)
  end

  def self.map_adverb(key : String)
    ADVERB_MAP[key] || new(:adv_term)
  end

  def self.map_conjunt(key : String)
    CONJUNCT_MAP[key] || new(:conjunct)
  end
end
