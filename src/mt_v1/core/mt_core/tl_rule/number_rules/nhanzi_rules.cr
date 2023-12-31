module M1::TlRule
  def fold_nhanzi!(node : MtNode, prev : MtNode? = nil) : MtNode
    return node unless (succ = node.succ?) && succ.is_a?(MtDefn)

    case succ.key
    when "点"  then fold_nhanzi_dian!(node, succ, prev)
    when "分"  then fold_number_minute!(node, succ)
    when "分钟" then fold_number_minute!(node, succ, is_time: true)
    else           node
    end
  end

  def fold_nhanzi_dian!(node : MtNode, succ : MtNode, prev : MtNode?) : MtNode
    result = keep_pure_numeral?(succ.succ?)

    if result.is_a?(MtNode)
      node.key = "#{node.key}#{succ.key}#{result.key}"
      node.val = "#{node.val} chấm #{result.val}" # TODO: correcting unit system
      return node.tap(&.fix_succ!(result.succ?))
    end

    prev || result ? fold_number_hour!(node, succ) : node
  end

  def keep_pure_numeral?(node : MtNode?) : Bool | MtNode
    return false unless node && node.is_a?(MtDefn)
    return true if node.key == "半" || node.key == "前后"

    return false unless node.numbers?
    return node unless (succ = node.succ?) && succ.is_a?(MtDefn)
    succ.key == "分" || succ.key == "分钟" ? true : node
  end
end
