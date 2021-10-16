struct CV::PosTag
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

  def self.map_auxils(key : ::String)
    pos = Pos::Auxils | Pos::Funcws

    {% begin %}
    case key
    {% for item in AUXILS %}
    {% for key in item[1] %}
    when {{key}} then new(Tag::{{item[0].id}}, pos)
    {% end %}
    {% end %}
    else new(Tag::Auxil, pos)
    end
    {% end %}
  end

  @[AlwaysInline]
  def auxils?
    @pos.auxils?
  end
end
