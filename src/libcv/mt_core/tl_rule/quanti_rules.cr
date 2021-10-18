module CV::TlRule
  def heal_quanti!(node : MtNode) : MtNode
    if val = PosTag::QTTIMES[node.key]?
      node.set!(val, PosTag::Qttime)
    elsif val = PosTag::QTVERBS[node.key]?
      node.set!(val, PosTag::Qtverb)
    elsif val = PosTag::QTNOUNS[node.key]?
      node.set!(val, PosTag::Qtnoun)
    else
      node
    end
  end

  QUANTI_PRE_APPRO = {
    "多" => "hơn",
    "余" => "trên",
    "来" => "chừng",
    "几" => "mấy",
  }

  def fold_pre_quanti_appro!(node : MtNode, succ : MtNode) : Tuple(MtNode, Int32)
    return {node, 0} unless val = QUANTI_PRE_APPRO[succ.key]?
    {fold_swap!(node, succ.set!(val), node.tag, dic: 5), 1}
  end

  QUANTI_SUF_APPRO = {
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
    return node unless succ && (val = QUANTI_SUF_APPRO[succ.key]?)
    fold_swap!(node, succ.set!(val), node.tag, dic: 6)
  end
end
