struct CV::PosTag
  # 后缀 - suffix - hậu tố
  AFFIXES = {
    {"ka", "SufAdjt", Pos::SufAdjts | Pos::Funcws},
    {"kn", "SufNoun", Pos::SufNouns | Pos::Funcws},
    {"kv", "SufVerb", Pos::SufVerbs | Pos::Funcws},
    {"k", "Suffix", Pos::Funcws},
  }

  @[AlwaysInline]
  def suffixes?
    @pos.suf_nouns? || @pos.suf_verbs? || @pos.suf_adjts?
  end

  @[AlwaysInline]
  def suf_nouns?
    @pos.suf_nouns?
  end

  @[AlwaysInline]
  def suf_verbs?
    @pos.suf_verbs?
  end

  @[AlwaysInline]
  def suf_adjts?
    @pos.suf_adjts?
  end
end
