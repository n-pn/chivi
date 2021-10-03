struct CV::PosTag
  AFFIXES = {
    {"h", "Prefix", Pos::Funcws}, # 前缀 - prefix - tiền tố
    {"k", "Suffix", Pos::Funcws}, # 后缀 - suffix - hậu tố

    {"ha", "PreAdjt", Pos::Prefixes, Pos::Funcws},
    {"hn", "PreNoun", Pos::Prefixes, Pos::Funcws},
    {"hv", "PreVerb", Pos::Prefixes, Pos::Funcws},

    {"ka", "SufAdjt", Pos::Suffixes, Pos::Funcws},
    {"kn", "SufNoun", Pos::Suffixes, Pos::Funcws},
    {"kv", "SufVerb", Pos::Suffixes, Pos::Funcws},

    {"kmen", "Suffix们", Pos::Funcws}, # hậu tố 们
    {"kshi", "Suffix时", Pos::Funcws}, # hậu tố 时
  }

  @[AlwaysInline]
  def prefixes?
    @pos.prefixes?
  end

  @[AlwaysInline]
  def suffixes?
    @pos.suffixes?
  end
end
