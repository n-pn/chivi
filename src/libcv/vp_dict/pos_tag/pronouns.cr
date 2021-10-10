struct CV::PosTag
  PRONOUNS = {

    # 代词 - pronoun - đại từ
    {"r", "Pronoun", Pos::Pronouns | Pos::Contws},
    # 人称代词 - personal pronoun - đại từ nhân xưng
    {"rr", "Propers", Pos::Pronouns | Pos::Contws},
    # 指示代词 - deictic pronoun - đại từ chỉ thị
    {"rz", "Prodeic", Pos::Pronouns | Pos::Contws},
    # 疑问代词 - interrogative pronoun - đại từ nghi vấn
    {"ry", "Prointr", Pos::Pronouns | Pos::Contws},

    # đại từ chỉ thị 这
    {"rzhe", "ProZhe", Pos::Pronouns | Pos::Contws},
    # đại từ chỉ thị 那
    {"rna1", "ProNa1", Pos::Pronouns | Pos::Contws},
    # đại từ nghi vấn 哪
    {"rna2", "ProNa2", Pos::Pronouns | Pos::Contws},
    # đại từ nghi vấn 几
    {"rji", "ProJi", Pos::Pronouns | Pos::Contws},
  }

  @[AlwaysInline]
  def pronouns?
    @pos.pronouns?
  end

  def prodeics?
    @tag.prodeic? || @tag.pro_zhe? || @tag.pro_na1?
  end

  def prointrs?
    @tag.prointr? || @tag.pro_na2? || @tag.pro_ji?
  end
end
