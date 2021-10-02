struct CV::PosTag
  MISCS = {

    # modifier (non-predicate noun modifier) - từ khu biệt
    {"b", "Modifier", Pos::Contws},
    # 区别词性惯用语 - noun modifier morpheme
    {"bl", "Modiform", Pos::Contws},

    # 代词 - pronoun - đại từ
    {"r", "Pronoun", Pos::Pronouns | Pos::Contws},
    # 人称代词 - personal pronoun - đại từ nhân xưng
    {"rr", "Propers", Pos::Pronouns | Pos::Contws},
    # 指示代词 - deictic pronoun - đại từ chỉ thị
    {"rz", "Prodeic", Pos::Pronouns | Pos::Contws},
    # 疑问代词 - interrogative pronoun - đại từ nghi vấn
    {"ry", "Prointr", Pos::Pronouns | Pos::Contws},
    # :Pronmorp => "rg"

    # 代词性语素 - pronominal morpheme

    # 数词 - numeral - số từ
    {"m", "Number", Pos::Numbers | Pos::Contws},
    # latin number 0 1 2 .. 9
    {"mx", "Numlat", Pos::Numbers | Pos::Contws},
    # 数量词 - numeral and quantifier - số + lượng
    {"mq", "Nquant", Pos::Numbers | Pos::Quantis | Pos::Contws},

    # 量词 - quantifier - lượng từ
    {"q", "Quanti", Pos::Quantis | Pos::Contws},
    # 动量词 - temporal classifier -  lượng động từ
    {"qv", "Qtverb", Pos::Quantis | Pos::Contws},
    # 时量词 - verbal classifier -  lượng từ thời gian
    {"qt", "Qttime", Pos::Quantis | Pos::Contws},

    # 成语 - idiom - thành ngữ
    {"i", "Idiom", Pos::Contws},
    # 简称 - abbreviation - viết tắt
    {"j", "Abbre", Pos::Contws},
    # 习惯用语 - Locution - quán ngữ
    {"l", "Locut", Pos::Contws},

    # 字符串 - non-word character string - hư từ khác
    {"x", "String", Pos::Strings | Pos::Contws},
    # 网址URL - url string
    {"xu", "Urlstr", Pos::Strings | Pos::Contws},
    # 非语素字 - for ascii art like emoji...
    {"xx", "Artstr", Pos::Strings | Pos::Contws},

    ################
    # 虚词 - hư từ #
    ###############

    {"h", "Prefix", Pos::Funcws}, # 前缀 - prefix - tiền tố
    {"k", "Suffix", Pos::Funcws}, # 后缀 - suffix - hậu tố

    {"kmen", "Kmen", Pos::Funcws}, # hậu tố 们
    {"kshi", "Kshi", Pos::Funcws}, # hậu tố 时

    {"d", "Adverb", Pos::Funcws}, # 副词 - adverb - phó từ (trạng từ)
    # dg adverbial morpheme
    # dl adverbial formulaic expression

    {"p", "Prepos", Pos::Preposes | Pos::Funcws},    # 介词 - preposition - giới từ
    {"pba", "Prepba", Pos::Preposes | Pos::Funcws},  # 介词 “把” - giới từ `bả`
    {"pbei", "Prebei", Pos::Preposes | Pos::Funcws}, # 介词 “被” - giới từ `bị`

    {"c", "Conjunct", Pos::Funcws},  # 连词 - conjunction - liên từ
    {"cc", "Concoord", Pos::Funcws}, # 并列连词 - coordinating conjunction - liên từ kết hợp

    {"e", "Interjection", Pos::Funcws},  # 叹词 - interjection/exclamation - thán từ
    {"y", "Modalparticle", Pos::Funcws}, # 语气词 - modal particle - ngữ khí
    {"o", "Onomatopoeia", Pos::Funcws},  # 拟声词 - onomatopoeia - tượng thanh

  }
end
