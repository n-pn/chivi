module CV::TlRule
  QUANTI_MAP = {
    "石" => "thạch",
    "两" => "lượng",
    "里" => "dặm",
    "米" => "mét",
    "帮" => "bang",
    "道" => "đạo",
    "股" => "cỗ",
    "更" => "canh",
    "重" => "tầng",
    "分" => "phân",
    "只" => "con",
    "本" => "quyển",
    "种" => "loại",
    "顿" => "đốn",
    "间" => "gian",
  }

  def heal_quanti!(node : MtNode) : MtNode
    return node unless val = QUANTI_MAP[node.key]?
    node.heal!(val, PosTag::Quanti)
  end
end
