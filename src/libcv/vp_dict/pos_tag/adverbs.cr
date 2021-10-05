struct CV::PosTag
  ADVERBS = {
    {"d", "Adverb", Pos::Adverbs | Pos::Funcws}, # 副词 - adverb - phó từ (trạng từ)
    # dg adverbial morpheme
    # dl adverbial formulaic expression
    # adverb 不
    {"dbu", "AdvBu", Pos::Adverbs | Pos::Funcws},
    # adverb 没
    {"dmei", "AdvMei", Pos::Adverbs | Pos::Funcws},
    # adverb 非
    {"dfei", "AdvFei", Pos::Adverbs | Pos::Funcws},
  }

  @[AlwaysInline]
  def adverbs?
    @pos.adverbs?
  end
end
