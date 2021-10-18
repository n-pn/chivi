struct CV::PosTag
  # 数词 - numeral - số từ

  NUMBERS = {

    # {"m", "Number", Pos::Numbers | Pos::Nquants | Pos::Contws},
    # # latin number 0 1 2 .. 9
    # {"mx", "Ndigit", Pos::Numbers | Pos::Nquants | Pos::Contws},
    # # hanzi number 零 〇 二
    # {"mz", "Nhanzi", Pos::Numbers | Pos::Nquants | Pos::Contws},
    # 序数 ordinal
    # {"mo", "Nordin", Pos::Numbers | Pos::Nquants | Pos::Contws},

    # 量词 - quantifier - lượng từ
    {"q", "Quanti", Pos::Quantis | Pos::Nquants | Pos::Contws},
    # 时量词 - verbal classifier -  lượng từ thời gian
    {"qt", "Qttime", Pos::Quantis | Pos::Nquants | Pos::Contws},
    # 数量词 - numeral and quantifier - số lượng từ
    {"mq", "Nquant", Pos::Nquants | Pos::Contws},

  }

  NUMPOS = Pos::Numbers | Pos::Nquants | Pos::Contws
  Number = new(Tag::Number, NUMPOS)
  Ndigit = new(Tag::Ndigit, NUMPOS)
  Nhanzi = new(Tag::Nhanzi, NUMPOS)

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

  NUMLAT_RE = /^\d+$/
  NUMHAN_RE = /^[零〇一二两三四五六七八九十百千万亿兆]+$/

  def self.map_numbers(key : ::String) : self
    case key
    when .matches?(NUMLAT_RE) then Ndigit
    when .matches?(NUMHAN_RE) then Nhanzi
    else                           Number
    end
  end
end
