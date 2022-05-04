struct CV::PosTag
  # 后缀 - suffix - hậu tố
  AFFIXES = {
    {"ka", "SufAdjt", Pos::Funcws},
    {"kn", "SufNoun", Pos::Funcws},
    {"kv", "SufVerb", Pos::Funcws},
    {"k", "Suffix", Pos::Funcws},
  }

  @[AlwaysInline]
  def suffixes?
    @tag.suf_noun? || @tag.suf_verb? || @tag.suf_adjt?
  end

  {% for type in AFFIXES %}
    {{ type[1].id }} = new(Tag::{{type[1].id}}, {{type[2]}})
  {% end %}
end
