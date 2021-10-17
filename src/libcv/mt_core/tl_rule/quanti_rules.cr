module CV::TlRule
  QUANTI_MAP = {
    "笔" => "bút",
    "家" => "nhà",
    "度" => "độ",
    # "号" => "ngày",
    "瓶" => "chai",
    "石" => "thạch",
    "两" => "lượng",
    "里" => "dặm",
    "米" => "mét",
    "帮" => "đám", # bọn/đàn/lũ/nhóm/tốp/bang
    "道" => "đạo", # đường/nét/vạch
    "股" => "cỗ",
    "更" => "canh",
    "重" => "tầng",
    "分" => "phân",
    "只" => "con",
    "本" => "quyển",
    "种" => "loại",
    "间" => "gian",
    "声" => "tiếng",
    "代" => "đời", # thời/nhà/lớp
    "圈" => "vòng",
    "顿" => "bữa",  # hồi/trận
    "场" => "trận", # bữa
    "轮" => "vòng", # vầng/vành/lượt
    "次" => "lượt", # lần/chuyến
    "步" => "bước",
    "盘" => "khay",
    "茬" => "vụ", # lứa/đợt
    "遍" => "lần",
    "餐" => "bữa",
    "趟" => "chuyến", # lần/hàng/dãy
    "番" => "phen",   # loại/dạng/hồi/lần
    "架" => "khung",
    "期" => "kỳ",
    "层" => "tầng",
    "门" => "môn",
    "回" => "hồi",

    "架次" => "lượt chiếc",
    "场次" => "lượt diễn",
    "人次" => "lượt người",
  }

  def heal_quanti!(node : MtNode) : MtNode
    return node unless val = QUANTI_MAP[node.key]?
    node.set!(val, PosTag::Quanti)
  end

  PRE_APPRO = {
    "多" => "hơn",
    "余" => "trên",
    "来" => "chừng",
    "几" => "mấy",
  }

  def fold_pre_quanti_appro!(node : MtNode, succ : MtNode) : MtNode
    return node unless val = PRE_APPRO[succ.key]?
    fold_swap!(node, succ.set!(val), node.tag, dic: 5)
  end

  APPROS = {
    "宽"  => "rộng",
    "高"  => "cao",
    "长"  => "dài",
    "远"  => "xa",
    "重"  => "nặng",
    "多"  => "hơn",
    "来"  => "chừng",
    "左右" => "khoảng",
    "前后" => "khoảng",
    "上下" => "khoảng",
    "间"  => "khoảng",
    "后间" => "khoảng",
    "后"  => "sau",
    "之后" => "sau",
    "时"  => "lúc",
    "之时" => "lúc",
    "上"  => "trên",
    "之上" => "trên",
    "下"  => "dưới",
    "之下" => "dưới",
    "前"  => "trước",
    "之前" => "trước",
    "里"  => "trong",
    "内"  => "trong",
    "中"  => "trong",
    "后内" => "trong",
    "后中" => "trong",
  }

  def fold_suf_quanti_appro!(node : MtNode, succ = node.succ?) : MtNode
    return node unless succ && (val = APPROS[succ.key]?)
    fold_swap!(node, succ, node.tag, dic: 6)
  end
end
