struct CV::PosTag
  AFFIXES = {
    {"ka", "SufAdjt", Pos::Suffixes, Pos::Funcws},
    {"kn", "SufNoun", Pos::Suffixes, Pos::Funcws},
    {"kv", "SufVerb", Pos::Suffixes, Pos::Funcws},

    {"kmen", "Suffix们", Pos::Funcws}, # hậu tố 们
    {"kshi", "Suffix时", Pos::Funcws}, # hậu tố 时
    {"k", "Suffix", Pos::Funcws},     # 后缀 - suffix - hậu tố chưa phân loại
  }

  @[AlwaysInline]
  def suffixes?
    @pos.suffixes?
  end
end
