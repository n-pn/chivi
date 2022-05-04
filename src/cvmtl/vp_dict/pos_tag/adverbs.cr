struct CV::PosTag
  # 副词 - adverb - phó từ (trạng từ)
  ADVERBS = {
    # dg adverbial morpheme
    # dl adverbial formulaic expression
    {"AdvBu"},
    {"AdvMei"},
    {"AdvFei"},
    {"Adverb"},
  }

  {% for type in ADVERBS %}
    {{ type[0].id }} = new(Tag::{{type[0].id}},  Pos::Adverbs)
  {% end %}

  def self.parse_adverb(key : String)
    case key
    when "不" then AdvBu
    when "没" then AdvMei
    when "非" then AdvFei
    else          Adverb
    end
  end
end
