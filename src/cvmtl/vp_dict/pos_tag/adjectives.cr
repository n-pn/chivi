struct CV::PosTag
  ADJTS = {
    # 形容词 - adjective - hình dung từ (tính từ)
    {"a", "Adjt", Pos::Adjts | Pos::Contws},
    # 名形词 nominal use of adjective - danh hình từ (danh + tính từ)
    {"an", "Ajno", Pos::Adjts | Pos::Nouns | Pos::Contws},
    # 副形词 - adverbial use of adjective - phó hình từ (phó + tính từ)
    {"ad", "Ajad", Pos::Adjts | Pos::Adverbs | Pos::Contws},

    # 形容词性惯用语 - adjectival formulaic expression -
    {"al", "Aform", Pos::Adjts | Pos::Contws},
    # 形容词性语素 - adjectival morpheme -
    {"ag", "Amorp", Pos::Adjts | Pos::Contws},

    # 状态词 - stative verb - trạng thái
    # {"az", "Adesc", Pos::Adjts | Pos::Contws},
    # modifier (non-predicate noun modifier) - 区别词 - từ khu biệt
    {"b", "Modifier", Pos::Adjts | Pos::Contws},
    # 区别词性惯用语 - noun modifier morpheme
    # {"bl", "Modiform", Pos::Adjts | Pos::Contws},
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
    when 'z' then Aform
    else          Adjt
    end
  end
end
