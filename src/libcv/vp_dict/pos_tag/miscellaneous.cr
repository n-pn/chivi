struct CV::PosTag
  MISCS = {

    # 代词 - pronoun - đại từ
    {"r", "Pronoun", Pos::Pronouns | Pos::Contws},
    # 人称代词 - personal pronoun - đại từ nhân xưng
    {"rr", "Propers", Pos::Pronouns | Pos::Contws},
    # 指示代词 - deictic pronoun - đại từ chỉ thị
    {"rz", "Prodeic", Pos::Pronouns | Pos::Contws},
    # 疑问代词 - interrogative pronoun - đại từ nghi vấn
    {"ry", "Prointr", Pos::Pronouns | Pos::Contws},

    # 成语 - idiom - thành ngữ
    {"i", "Idiom", Pos::Contws},
    # 简称 - abbreviation - viết tắt
    # {"j", "Abbre", Pos::Contws},
    # 习惯用语 - Locution - quán ngữ
    # {"l", "Locut", Pos::Contws},

    # 字符串 - non-word character string - hư từ khác
    {"x", "String", Pos::Strings | Pos::Contws},
    # 网址URL - url string
    {"xu", "Urlstr", Pos::Strings | Pos::Contws},
    # 非语素字 - for ascii art like emoji...
    {"xx", "Artstr", Pos::Strings | Pos::Contws},

    ################
    # 虚词 - hư từ #
    ###############

    {"p", "Prepos", Pos::Preposes | Pos::Funcws},    # 介词 - preposition - giới từ
    {"pba", "Prepba", Pos::Preposes | Pos::Funcws},  # 介词 “把” - giới từ `bả`
    {"pbei", "Prebei", Pos::Preposes | Pos::Funcws}, # 介词 “被” - giới từ `bị`
    {"pdui", "Predui", Pos::Preposes | Pos::Funcws}, # 介词 “对” - giới từ `đối`

    {"c", "Conjunct", Pos::Funcws},  # 连词 - conjunction - liên từ
    {"cc", "Concoord", Pos::Funcws}, # 并列连词 - coordinating conjunction - liên từ kết hợp

    {"e", "Interjection", Pos::Funcws},  # 叹词 - interjection/exclamation - thán từ
    {"y", "Modalparticle", Pos::Funcws}, # 语气词 - modal particle - ngữ khí
    {"o", "Onomatopoeia", Pos::Funcws},  # 拟声词 - onomatopoeia - tượng thanh
  }

  @[AlwaysInline]
  def pronouns?
    @pos.pronouns?
  end

  @[AlwaysInline]
  def preposes?
    @pos.preposes?
  end

  @[AlwaysInline]
  def strings?
    @pos.strings?
  end
end
