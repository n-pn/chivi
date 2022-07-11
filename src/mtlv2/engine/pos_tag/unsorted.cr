struct MtlV2::PosTag
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
    {"cc", "Concoord", Pos::Funcws | Pos::Junction},

    # 叹词 - interjection/exclamation - thán từ
    {"e", "Exclam", Pos::Funcws},
    # 语气词 - modal particle - ngữ khí
    {"y", "Mopart", Pos::Funcws},
    # 拟声词 - onomatopoeia - tượng thanh
    {"o", "Onomat", Pos::Funcws},

    # complex phrase ac as verb
    {"~vp", "VerbPhrase", Pos::Verbal | Pos::Contws},
    # complex phrase act as adjective
    {"~ap", "AdjtPhrase", Pos::Adjective | Pos::Contws},
    # complex phrase act as noun
    {"~np", "NounPhrase", Pos::Nominal | Pos::Contws},
    # definition phrase
    {"~dp", "DefnPhrase", Pos::Contws},
    # prepos phrase
    {"~pn", "PrepClause", Pos::Contws},
    # subject + verb clause
    {"~sv", "VerbClause", Pos::Contws},
    # subject + adjt clause
    {"~sa", "AdjtClause", Pos::Contws},
  }

  {% for type in MISCS %}
    {{ type[1].id }} = new(Tag::{{type[1].id}}, {{type[2]}})
  {% end %}

  def self.parse_miscs(tag : String) : self
    case tag
    when "j" then Noun
    when "i" then Idiom
    when "l" then Idiom
    when "z" then Aform
    when "e" then Exclam
    when "y" then Mopart
    when "o" then Onomat
    else          Unkn
    end
  end

  def self.parse_conjunct(tag : String, key : String)
    return Concoord if tag[1]? == 'c'
    return Conjunct unless key.in?("但", "又", "或", "或是")
    new(Tag::Conjunct, Pos::Funcws | Pos::Junction)
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

  def self.parse_extra(tag : String) : self
    case tag
    when "~np" then NounPhrase
    when "~vp" then VerbPhrase
    when "~ap" then AdjtPhrase
    when "~dp" then DefnPhrase
    when "~pp" then PrepClause
    when "~sv" then VerbClause
    when "~sa" then AdjtClause
    else            Unkn
    end
  end
end
