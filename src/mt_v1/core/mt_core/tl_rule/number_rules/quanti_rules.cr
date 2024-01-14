module M1::TlRule
  def heal_quanti!(node : MtNode) : MtNode
    return node unless node.is_a?(MtDefn)
    not_quanti?(node) ? node : SpDict.fix_quanti!(node)
  end

  def not_quanti?(node : MtNode)
    # abort transform if node is certainly a verb
    return false unless node.verbal? && (succ = node.succ?)
    succ.ule? || succ.comma? || succ.colon? || succ.pstop?
  end

  QUANTI_PRE_APPRO = {
    "多" => "hơn",
    "来" => "chừng",
    "余" => "trên",
    "几" => "mấy",
  }

  def fold_pre_quanti_appro!(node : MtNode, succ : MtNode) : Tuple(MtNode, Int32)
    case succ.key
    when "多"
      return {node, 0} unless is_pre_quanti_appro?(node)
      node = fold!(node, succ.set!("hơn"), node.tag, dic: 5, flip: true)
    when "来"
      return {node, 0} unless is_pre_quanti_appro?(node)
      node = fold!(node, succ.set!("chừng"), node.tag, dic: 5, flip: true)
    when "余"
      node = fold!(node, succ.set!("trên"), node.tag, dic: 5, flip: true)
    when "几"
      node = fold!(node, succ.set!("mấy"), node.tag, dic: 5)
    else
      return {node, 0}
    end

    node = fold!(node, succ) if succ = node.succ?
    {node, 1}
  end

  def is_pre_quanti_appro?(node : MtNode)
    return false unless node.is_a?(MtDefn)
    node.to_int?.try { |x| x > 10 && x % 10 == 0 } || false
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

    case succ.key
    when "来", "多"
      return node unless succ.to_int?.try { |x| x == 10 || x % 10 != 0 }
    end

    fold!(node, succ.set!(val), node.tag, dic: 6, flip: true)
  end
end
