struct CV::PosTag
  # 介词 - preposition - giới từ
  PREPOSES = {
    {"PrepBa"},
    {"PreBei"},
    {"PreDui"},
    {"Prepos"},
  }

  PREPOS = Pos::Preposes | Pos::Funcws

  {% for type in PREPOSES %}
    {{ type[0].id }} = new(Tag::{{type[0].id}}, PREPOS)
  {% end %}

  def self.map_preposes(key : ::String)
    case key
    when "把" then PrepBa
    when "被" then PreBei
    when "对" then PreDui
    else          Prepos
    end
  end

  @[AlwaysInline]
  def preposes?
    @pos.preposes?
  end
end
