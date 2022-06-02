struct CV::PosTag
  ADJTS = {
    # 形容词 - adjective - hình dung từ (tính từ)
    {"a", "Adjt", Pos::Adjective | Pos::Contws},
    # 名形词 nominal use of adjective - danh hình từ (danh + tính từ)
    {"an", "Ajno", Pos::Mixed | Pos::Adjective | Pos::Nominal | Pos::Contws},
    # 副形词 - adverbial use of adjective - phó hình từ (phó + tính từ)
    {"ad", "Ajad", Pos::Mixed | Pos::Adjective | Pos::Adverbial | Pos::Contws},

    # 形容词性惯用语 - adjectival formulaic expression -
    {"al", "Aform", Pos::Adjective | Pos::Contws},
    # 形容词性语素 - adjectival morpheme -
    # {"ag", "Amorp", Pos::Adjective | Pos::Contws},

    # {"am", "AjtMeasure", Pos.flags(Adjective, Measure, Contws)},

    # 状态词 - stative verb - trạng thái
    # {"az", "Adesc", Pos::Adjective | Pos::Contws},
    # modifier (non-predicate noun modifier) - 区别词 - từ khu biệt
    {"b", "Modi", Pos.flags(Adjective, Modifier, Contws)},
    # 区别词性惯用语 - noun modifier morpheme
    # {"bl", "Modiform", Pos::Adjective | Pos::Contws},
  }

  {% for type in ADJTS %}
    {{ type[1].id }} = new(Tag::{{type[1].id}}, {{type[2]}})
  {% end %}

  def self.parse_adjt(tag : String, key : String)
    case tag[1]?
    when nil then Adjt
    when 'n' then Ajno
    when 'd' then Ajad
    when 'l' then Aform
    when 'b' then Modi
    when 'z' then Aform
    when 'm'
      new(Tag::Adjt, Pos.flags(Adjective, Measure, Special))
    else
      key.size > 1 ? Adjt : new(Tag::Adjt, Pos.flags(Adjective, Modifier))
    end
  end
end
