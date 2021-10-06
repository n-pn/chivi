module CV::TlRule
  QUANTI_MAP = {
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

    "架次" => "lượt chiếc",
    "场次" => "lượt diễn",
    "人次" => "lượt người",
  }

  def heal_quanti!(node : MtNode) : MtNode
    return node unless val = QUANTI_MAP[node.key]?
    node.heal!(val, PosTag::Quanti)
  end
end
