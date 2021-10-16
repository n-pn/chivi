struct CV::PosTag
  UNIQS = {
    # adjective "好"
    {"ahao", "Ahao", Pos::Adjts | Pos::Vcompls | Pos::Uniqs | Pos::Contws},

    # động từ đặc biệt 上
    {"vshang", "Vshang", Pos::Verbs | Pos::Vcompls | Pos::Uniqs | Pos::Contws},
    # động từ đặc biệt 下
    {"vxia", "Vxia", Pos::Verbs | Pos::Vcompls | Pos::Uniqs | Pos::Contws},
  }

  @[AlwaysInline]
  def uniqs?
    @pos.uniqs?
  end

  @[AlwaysInline]
  def vcompls?
    @pos.vcompls?
  end
end
