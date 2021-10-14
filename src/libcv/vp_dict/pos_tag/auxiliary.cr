struct CV::PosTag
  AUXILS = {
    {"u", "Auxi", Pos::Auxils | Pos::Funcws},      # 助词 - particle/auxiliary - trợ từ
    {"uzhi", "Uzhi", Pos::Auxils | Pos::Funcws},   # 之
    {"uzhe", "Uzhe", Pos::Auxils | Pos::Funcws},   # 着
    {"ule", "Ule", Pos::Auxils | Pos::Funcws},     # 了 喽
    {"uguo", "Uguo", Pos::Auxils | Pos::Funcws},   # 过
    {"ude1", "Ude1", Pos::Auxils | Pos::Funcws},   # 的 底
    {"ude2", "Ude2", Pos::Auxils | Pos::Funcws},   # 地
    {"ude3", "Ude3", Pos::Auxils | Pos::Funcws},   # 得
    {"usuo", "Usuo", Pos::Auxils | Pos::Funcws},   # 所
    {"udeng", "Udeng", Pos::Auxils | Pos::Funcws}, # 等 等等 云云
    {"uyy", "Uyy", Pos::Auxils | Pos::Funcws},     # 一样 一般 似的 般
    {"udh", "Udh", Pos::Auxils | Pos::Funcws},     # 的话
    {"uls", "Uls", Pos::Auxils | Pos::Funcws},     # 来讲 来说 而言 说来
    {"ulian", "Ulian", Pos::Auxils | Pos::Funcws}, # 连 （“连小学生都会”）
  }

  @[AlwaysInline]
  def auxils?
    @pos.auxils?
  end
end
