struct CV::PosTag
  MISCS = {

    # 成语 - idiom - thành ngữ
    {"i", "Idiom", Pos::Contws},
    # 简称 - abbreviation - viết tắt
    # {"j", "Abbre", Pos::Contws},
    # 习惯用语 - Locution - quán ngữ
    # {"l", "Locut", Pos::Contws},

    # 字符串 - non-word character string - hư từ khác
    {"x", "String", Pos::Strings | Pos::Contws},
    # 网址URL - url string | 非语素字 - for ascii art like emoji...
    {"xx", "Rawstr", Pos::Strings | Pos::Contws},

    ################
    # 虚词 - hư từ #
    ###############

    {"c", "Conjunct", Pos::Funcws},  # 连词 - conjunction - liên từ
    {"cc", "Concoord", Pos::Funcws}, # 并列连词 - coordinating conjunction - liên từ kết hợp

    {"e", "Interjection", Pos::Funcws},  # 叹词 - interjection/exclamation - thán từ
    {"y", "Modalparticle", Pos::Funcws}, # 语气词 - modal particle - ngữ khí
    {"o", "Onomatopoeia", Pos::Funcws},  # 拟声词 - onomatopoeia - tượng thanh

    {"vp", "Vphrase", Pos::Verbs | Pos::Contws}, # verb phrase
    {"np", "Nphrase", Pos::Nouns | Pos::Contws}, # noun phrase

    {"sv", "Vclause", Pos::Contws}, # subject + verb clause
    {"sa", "Aclause", Pos::Contws}, # subject + adjt clause
    {"dp", "Dphrase", Pos::Contws}, # cụm định ngữ/definition
    {"pp", "Pphrase", Pos::Contws}, # cụm giới từ
  }

  @[AlwaysInline]
  def strings?
    @pos.strings?
  end

  @[AlwaysInline]
  def uniqs?
    @pos.uniqs?
  end
end
