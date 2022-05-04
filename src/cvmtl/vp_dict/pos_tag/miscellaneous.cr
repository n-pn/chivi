struct CV::PosTag
  MISCS = {

    # 成语 - idiom - thành ngữ
    {"i", "Idiom", Pos::Contws},
    # 简称 - abbreviation - viết tắt
    # {"j", "Abbre", Pos::Contws},
    # 习惯用语 - Locution - quán ngữ
    # {"l", "Locut", Pos::Contws},

    # 字符串 - non-word character string - hư từ khác
    {"x", "Litstr", Pos::Strings},
    # 网址URL - url string | 非语素字 - for ascii art like emoji...
    {"xl", "Urlstr", Pos::Strings},
    # 非语素字 - for ascii art like emoji...
    {"xx", "Fixstr", Pos::Strings},

    # 连词 - conjunction - liên từ
    {"c", "Conjunct", Pos::Funcws},
    # 并列连词 - coordinating conjunction - liên từ kết hợp
    {"cc", "Concoord", Pos::Funcws},

    # 叹词 - interjection/exclamation - thán từ
    {"e", "Exclam", Pos::Funcws},
    # 语气词 - modal particle - ngữ khí
    {"y", "Mopart", Pos::Funcws},
    # 拟声词 - onomatopoeia - tượng thanh
    {"o", "Onomat", Pos::Funcws},

    # subject + verb clause
    {"s-v", "VerbClause", Pos::Contws},
    # subject + adjt clause
    {"s-a", "AdjtClause", Pos::Contws},
    # cụm định ngữ/definition
    {"~dp", "DefnPhrase", Pos::Contws},
    # cụm giới từ
    {"~pp", "PrepPhrase", Pos::Contws},
  }

  {% for type in MISCS %}
    {{ type[1].id }} = new(Tag::{{type[1].id}}, {{type[2]}})
  {% end %}
end
