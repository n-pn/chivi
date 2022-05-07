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
    {"~sv", "VerbClause", Pos::Contws},
    # subject + adjt clause
    {"~sa", "AdjtClause", Pos::Contws},
    # complex phrase ac as verb
    {"~vp", "VerbPhrase", Pos::Verbs | Pos::Contws},
    # complex phrase act as adjective
    {"~ap", "AdjtPhrase", Pos::Verbs | Pos::Contws},
    # complex phrase act as noun
    {"~np", "NounPhrase", Pos::Nouns | Pos::Contws},
    # definition phrase
    {"~dp", "DefnPhrase", Pos::Contws},
    # prepos phrase
    {"~pp", "PrepPhrase", Pos::Contws},
  }

  {% for type in MISCS %}
    {{ type[1].id }} = new(Tag::{{type[1].id}}, {{type[2]}})
  {% end %}

  # ameba:disable Metrics/CyclomaticComplexity
  def self.parse_miscs(tag : String) : self
    case tag
    when "j"  then Noun
    when "i"  then Idiom
    when "l"  then Idiom
    when "z"  then Aform
    when "x"  then Litstr
    when "xl" then Urlstr
    when "xx" then Fixstr
    when "c"  then Conjunct
    when "cc" then Concoord
    when "e"  then Exclam
    when "y"  then Mopart
    when "o"  then Onomat
    else           Unkn
    end
  end

  def self.parse_extra(tag : String) : self
    case tag
    when "~sv" then VerbClause
    when "~sa" then AdjtClause
    when "~np" then NounPhrase
    when "~vp" then VerbPhrase
    when "~ap" then AdjtPhrase
    when "~dp" then DefnPhrase
    when "~pp" then PrepPhrase
    else            Unkn
    end
  end
end
