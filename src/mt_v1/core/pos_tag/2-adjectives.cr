struct M1::PosTag
  ADJTS = {
    # 形容词 - adjective - hình dung từ (tính từ)
    {"a", "Adjt", Pos::Adjective},
    # 名形词 nominal use of adjective - danh hình từ (danh + tính từ)
    {"an", "Ajno", Pos::Polysemy | Pos::Adjective | Pos::Nominal},
    # 副形词 - adverbial use of adjective - phó hình từ (phó + tính từ)
    {"ad", "Ajad", Pos::Polysemy | Pos::Adjective | Pos::Adverbial},

    # 形容词性惯用语 - adjectival formulaic expression -
    {"al", "Aform", Pos::Adjective},
    # 形容词性语素 - adjectival morpheme -
    # {"ag", "Amorp", Pos::Adjective},

    # 状态词 - stative verb - trạng thái
    # {"az", "Adesc", Pos::Adjective},
    # modifier (non-predicate noun modifier) - 区别词 - từ khu biệt
    {"ab", "Modi", Pos::Adjective},
    # 区别词性惯用语 - noun modifier morpheme
    # {"bl", "Modiform", Pos::Adjective},
  }

  {% for type in ADJTS %}
    {{ type[1].id }} = new(Tag::{{type[1].id}}, {{type[2]}})
  {% end %}

  def self.parse_adjt(tag : String, key : String)
    case tag[1]?
    when 'n' then Ajno
    when 'd' then Ajad
    when 'b' then Modi
    when 'l' then Aform
    when 'z' then Aform
    else          Adjt
    end
  end
end
