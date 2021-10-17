struct CV::PosTag
  NUMBERS = {

    # 数词 - numeral - số từ
    {"m", "Number", Pos::Numbers | Pos::Nquants | Pos::Contws},
    # latin number 0 1 2 .. 9
    {"mx", "Numlat", Pos::Numbers | Pos::Nquants | Pos::Contws},
    # hanzi number 零 〇 二
    {"mz", "Numhan", Pos::Numbers | Pos::Nquants | Pos::Contws},
    # 序数 ordinal
    # {"mo", "Nordin", Pos::Numbers | Pos::Nquants | Pos::Contws},

    # 量词 - quantifier - lượng từ
    {"q", "Quanti", Pos::Quantis | Pos::Nquants | Pos::Contws},
    # 时量词 - verbal classifier -  lượng từ thời gian
    {"qt", "Qttime", Pos::Quantis | Pos::Nquants | Pos::Contws},
    # 数量词 - numeral and quantifier - số lượng từ
    {"mq", "Nquant", Pos::Nquants | Pos::Contws},

  }

  @[AlwaysInline]
  def numbers?
    @pos.numbers?
  end

  @[AlwaysInline]
  def quantis?
    @pos.quantis?
  end

  @[AlwaysInline]
  def nquants?
    @pos.nquants?
  end
end
