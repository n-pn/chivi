struct CV::PosTag
  NOUNS = {
    # 名词 - noun - danh từ chung
    {"n", "Noun", Pos::Nouns | Pos::Contws},
    # 名词性语素 - nominal formulaic expression
    {"nl", "Nform", Pos::Nouns | Pos::Contws},
    # 名词性语素 - nominal morpheme
    {"ng", "Nmorp", Pos::Nouns | Pos::Contws},

    # 人名 - person name - tên người
    {"nr", "Person", Pos::Nouns | Pos::Contws},
    # 姓氏 - family name - dòng họ
    {"nf", "Linage", Pos::Nouns | Pos::Contws},

    # danh xưng: chức danh, nghề nghiệp, địa vị
    {"nw", "Ptitle", Pos::Nouns | Pos::Contws},

    # dòng họ + danh xưng
    {"nfw", "Snwtit", Pos::Nouns | Pos::Contws},

    # 地名 - location name - địa danh
    {"ns", "Locname", Pos::Nouns | Pos::Contws},

    # 机构团体名 - organization name - tổ chức
    {"nt", "Orgname", Pos::Nouns | Pos::Contws},

    # 其它专名 - other proper noun - tên riêng khác
    {"nz", "Nother", Pos::Nouns | Pos::Contws},

    # 时间词 - time word - thời gian
    {"t", "Time", Pos::Nouns | Pos::Contws},

    # 时间词性语素 - time word morpheme
    {"tg", "Tmorp", Pos::Nouns | Pos::Contws},

    # 处所词 - place word - nơi chốn
    {"s", "Place", Pos::Nouns | Pos::Contws},
    # 方位词 - space word - phương vị
    {"f", "Space", Pos::Nouns | Pos::Contws},
  }

  @[AlwaysInline]
  def nouns?
    @pos.nouns?
  end
end
