struct CV::PosTag
  SOUND_MAP    = load_map("sounds")
  ADVERB_MAP   = load_map("adverbs")
  SUFFIX_MAP   = load_map("suffixes")
  CONJUNCT_MAP = load_map("conjuncts")
  UNIQWORD_MAP = load_map("uniq_words")

  def self.map_sound(key : String)
    SOUND_MAP[key] ||= new(:onomat)
  end

  def self.map_adverb(key : String)
    ADVERB_MAP[key] ||= new(:adv_term)
  end

  def self.map_suffix(key : String)
    SUFFIX_MAP[key] ||= begin
      key[0] == '之' ? new(:suf_zhi) : new(:suf_noun)
    end
  end

  def self.map_conjunct(key : String)
    CONJUNCT_MAP[key] ||= new(:conjunct)
  end

  def self.map_uniqword(key : String)
    UNIQWORD_MAP[key] ||= new(:uniqword)
  end

  NOUN_CAST = load_map("cast_nouns", MtlPos.flags(Object))
  VERB_CAST = load_map("cast_verbs", MtlPos.flags(None))
  ADJT_CAST = load_map("cast_adjts", MtlPos.flags(None))
  ADVB_CAST = load_map("cast_advbs", MtlPos.flags(None))

  def self.cast_noun(key : String)
    NOUN_CAST[key] || Nword
  end

  def self.cast_verb(key : String)
    VERB_CAST[key] || Verb
  end

  def self.cast_adjt(key : String)
    ADJT_CAST[key] || Adjt
  end

  def self.cast_advb(key : String)
    ADVB_CAST[key] || new(:adv_term)
  end
end
