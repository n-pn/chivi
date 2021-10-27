struct CV::PosTag
  # 数词 - numeral - số từ
  NB_POS = Pos::Numbers | Pos::Numeric | Pos::Contws
  Ndigit = new(Tag::Ndigit, NB_POS)
  Nhanzi = new(Tag::Nhanzi, NB_POS)
  Number = new(Tag::Number, NB_POS)

  # # 量词 - quantifier - lượng từ
  QT_POS = Pos::Quantis | Pos::Numeric | Pos::Contws
  Qtnoun = new(Tag::Qtnoun, QT_POS)
  Qttime = new(Tag::Qttime, QT_POS)
  Qtverb = new(Tag::Qtverb, QT_POS)

  # 数量词 - numeral and quantifier - số lượng từ
  NQ_POS = Pos::Nquants | Pos::Numeric | Pos::Contws
  Nqnoun = new(Tag::Nqnoun, NQ_POS)
  Nqtime = new(Tag::Nqtime, NQ_POS)
  Nqverb = new(Tag::Nqverb, NQ_POS)
  Nqiffy = new(Tag::Nqiffy, NQ_POS) # unknown nquants

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

  @[AlwaysInline]
  def numeric?
    @pos.numeric?
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

  QTTIMES = {
    "秒"  => "giây",
    "分钟" => "phút",
    "小时" => "giờ",
    "日"  => "ngày",
    # "号"  => "ngày",
    "月"  => "tháng",
    "个月" => "tháng",
    "年"  => "năm",
    "岁"  => "tuổi",
    "周"  => "tuần",
    "席"  => "bữa",
  }

  QTVERBS = {
    "次"  => "lượt", # lần/chuyến
    "回"  => "hồi",
    "遍"  => "lần",
    "趟"  => "chuyến", # lần/hàng/dãy
    "下"  => "phát",
    "下儿" => "phát",
    "顿"  => "chầu", # hồi/trận
    "番"  => "phen", # loại/dạng/hồi/lần
    "阵"  => "trận",
    "会"  => "lúc",
    "会儿" => "lát",
  }

  QTNOUNS = {
    "招" => "chiêu",
    "笔" => "bút",
    "家" => "nhà",
    "度" => "độ",
    "处" => "chỗ",
    "瓶" => "chai",
    "石" => "thạch",
    # "两"  => "lượng",
    "里"  => "dặm",
    "米"  => "mét",
    "帮"  => "đám", # bọn/đàn/lũ/nhóm/tốp/bang
    "道"  => "đạo", # đường/nét/vạch
    "股"  => "cỗ",
    "更"  => "canh",
    "重"  => "tầng",
    "分"  => "phân",
    "只"  => "con",
    "本"  => "quyển",
    "种"  => "loại",
    "间"  => "gian",
    "声"  => "tiếng",
    "代"  => "đời", # thời/nhà/lớp
    "圈"  => "vòng",
    "场"  => "trận", # bữa
    "轮"  => "vòng", # vầng/vành/lượt
    "步"  => "bước",
    "盘"  => "khay",
    "茬"  => "vụ", # lứa/đợt
    "餐"  => "bữa",
    "架"  => "khung",
    "期"  => "kỳ",
    "层"  => "tầng",
    "门"  => "môn",
    "转"  => "vòng",
    "种"  => "loài",
    "架次" => "lượt chiếc",
    "场次" => "lượt diễn",
    "人次" => "lượt người",

  }

  def self.map_quantis(key : ::String) : self
    return Qttime if QTTIMES.has_key?(key)
    return Qtverb if QTVERBS.has_key?(key)
    Qtnoun
  end

  NUMCHR_RE = /[零〇一二两三四五六七八九十百千万亿兆多每]/

  def self.map_nquants(key : ::String) : self
    key = key.sub(NUMCHR_RE, "")
    case
    when QTTIMES.has_key?(key) then Nqtime
    when QTNOUNS.has_key?(key) then Nqnoun
    when QTVERBS.has_key?(key) then Nqverb
    else                            Nqiffy
    end
  end
end
