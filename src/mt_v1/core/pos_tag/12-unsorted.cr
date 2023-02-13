struct M1::PosTag
  MISCS = {
    # 成语 - idiom - thành ngữ
    {"i", "Idiom", Pos::None},
    # 简称 - abbreviation - viết tắt
    # {"j", "Abbre", Pos::None},
    # 习惯用语 - Locution - quán ngữ
    # {"l", "Locut", Pos::None},

    # 字符串 - non-word character string - hư từ khác
    {"x", "Litstr", Pos::Strings},
    # 网址URL - url string | 非语素字
    {"xl", "Urlstr", Pos::Strings},
    # 非语素字 - for ascii art like emoji...
    {"xx", "Fixstr", Pos::Strings},

    # 叹词 - interjection/exclamation - thán từ
    {"xe", "Exclam", Pos::None},
    # 语气词 - modal particle - ngữ khí
    {"xy", "Mopart", Pos::None},
    # 拟声词 - onomatopoeia - tượng thanh
    {"xo", "Onomat", Pos::None},

    # 连词 - conjunction - liên từ
    {"c", "Conjunct", Pos::None},
    # 并列连词 - coordinating conjunction - liên từ kết hợp
    {"cc", "Concoord", Pos::None},

    # complex phrase ac as verb
    {"~vp", "VerbPhrase", Pos::Verbal},
    # complex phrase act as adjective
    {"~ap", "AdjtPhrase", Pos::Verbal},
    # complex phrase act as noun
    {"~np", "NounPhrase", Pos::Nominal},
    # definition phrase
    {"~dp", "DefnPhrase", Pos::None},
    # prepos phrase
    {"~pn", "PrepClause", Pos::None},
    # subject + verb clause
    {"~sv", "VerbClause", Pos::None},
    # subject + adjt clause
    {"~sa", "AdjtClause", Pos::None},
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
