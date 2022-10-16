module MT::PosTag
  SOUND_MAP    = load_map("map_sound")
  ADVERB_MAP   = load_map("map_advb")
  SUFFIX_MAP   = load_map("map_suff")
  CONJUNCT_MAP = load_map("map_conj")
  UNIQWORD_MAP = load_map("map_uniq", :mixedpos)

  def self.map_sound(key : String)
    SOUND_MAP[key]? || make(:onomat)
  end

  def self.map_adverb(key : String)
    ADVERB_MAP[key]? || make(:adv_term)
  end

  def self.map_suffix(key : String)
    SUFFIX_MAP[key] ||= key[0] == '之' ? make(:suf_zhi) : make(:suf_noun)
  end

  def self.map_conjunct(key : String)
    CONJUNCT_MAP[key]? || make(:conjunct)
  end

  def self.map_uniqword(key : String)
    UNIQWORD_MAP[key]? || make(:uniqword)
  end

  ###

  NOT_VCOMPL_MAP = load_map("not_vcompl")
  NOT_QUANTI_MAP = load_map("not_quanti")

  def self.not_vcompl(key : String)
    NOT_VCOMPL_MAP[key]? || make(:verb)
  end

  def self.not_quanti(key : String)
    NOT_QUANTI_MAP[key]? || Nword
  end

  ###

  TO_NOUN_MAP = load_map("to_noun", MtlPos.flags(Object))
  TO_VERB_MAP = load_map("to_verb", MtlPos.flags(None))
  TO_ADJT_MAP = load_map("to_adjt", MtlPos.flags(None))
  TO_ADVB_MAP = load_map("to_advb", MtlPos.flags(None))

  def self.cast_noun(key : String)
    TO_NOUN_MAP[key]? || Nword
  end

  def self.cast_verb(key : String)
    TO_VERB_MAP[key]? || Verb
  end

  def self.cast_adjt(key : String)
    TO_ADJT_MAP[key]? || Adjt
  end

  def self.cast_advb(key : String)
    TO_ADVB_MAP[key]? || make(:adv_term)
  end
end
