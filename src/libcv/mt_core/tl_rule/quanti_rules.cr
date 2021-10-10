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

  def nquant_is_complement?(node : MtNode) : Bool
    case node.key[-1]?
    when '次', '遍', '趟', '回', '声', '下', '把'
      true
    else
      false
    end
  end

  def fold_pre_quanti_appro!(node : MtNode, succ : MtNode) : MtNode
    case succ.key
    when "多" then node.fold!("hơn #{node.val}")
    when "余" then node.fold!("trên #{node.val}")
    when "来" then node.fold!("chừng #{node.val}")
    when "几" then node.fold!("#{node.val} mấy")
    else          node
    end
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
    node.fold!(succ, "#{val} #{node.val}")
  end
end
