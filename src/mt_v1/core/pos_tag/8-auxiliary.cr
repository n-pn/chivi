struct M1::PosTag
  # 助词 - particle/auxiliary - trợ từ

  AUXILS = {
    {"Uzhi", ["之"]},
    {"Uzhe", ["着"]},
    {"Ule", ["了", "喽"]},
    {"Uguo", ["过"]},
    {"Ude1", ["的", "底"]},
    {"Ude2", ["地"]},
    {"Ude3", ["得"]},
    {"Usuo", ["所"]},
    {"Udeng", ["等", "等等", "云云"]},
    {"Uyy", ["一样", "一般", "似的", "般"]},
    {"Udh", ["的话"]},
    {"Uls", ["来讲", "来说", "而言", "说来"]},
    {"Ulian", ["连"]},
  }

  Auxil = new(Tag::Auxil, Pos::None)

  {% for type in AUXILS %}
    {{ type[0].id }} = new(Tag::{{type[0].id}}, Pos::None)
  {% end %}

  def self.parse_auxil(key : String)
    {% begin %}
    case key
    {% for item in AUXILS %}
      {% for key in item[1] %}
      when {{key}} then {{item[0].id}}
      {% end %}
    {% end %}
    else Auxil
    end
    {% end %}
  end
end
