struct CV::PosTag
  # 副词 - adverb - phó từ (trạng từ)
  ADVERBS = {
    # dg adverbial morpheme
    # dl adverbial formulaic expression
    {"AdvBu", "不"},
    {"AdvMei", "没"},
    {"AdvFei", "非"},
  }

  def self.map_adverbs(key : ::String)
    pos = Pos::Adverbs | Pos::Funcws

    {% begin %}
    case key
    {% for item in AUXILS %}
    when {{item[1]}} then new(Tag::{{item[0].id}}, pos)
    {% end %}
    else new(Tag::Adverb, pos)
    end
    {% end %}
  end

  @[AlwaysInline]
  def adverbs?
    @pos.adverbs?
  end
end
