struct CV::PosTag
  MISCS = {
    # 成语 - idiom - thành ngữ
    {"i", "Idiom", Pos::None},
    # 简称 - abbreviation - viết tắt
    # {"j", "Abbre", Pos::None},
    # 习惯用语 - Locution - quán ngữ
    # {"l", "Locut", Pos::None},

    # 连词 - conjunction - liên từ
    {"c", "Conjunct", Pos::None},
    # 并列连词 - coordinating conjunction - liên từ kết hợp
    {"cc", "Concoord", Pos::None},

  }

  {% for type in MISCS %}
    {{ type[1].id }} = new(Tag::{{type[1].id}}, {{type[2]}})
  {% end %}

  def self.parse_miscs(tag : String) : self
    case tag
    when "j"  then Noun
    when "i"  then Idiom
    when "l"  then Idiom
    when "z"  then Aform
    when "c"  then Conjunct
    when "cc" then Concoord
    when "e"  then Exclam
    when "y"  then Mopart
    when "o"  then Onomat
    else           Unkn
    end
  end

  def self.parse_other(tag : String) : self
    case tag[1]?
    when 'c' then Exclam
    when 'e' then Exclam
    when 'y' then Mopart
    when 'o' then Onomat
    when 'l' then Urlstr
    when 'x' then Fixstr
    else          Litstr
    end
  end
end
