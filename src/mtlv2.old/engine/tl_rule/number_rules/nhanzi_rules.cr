module MT::TlRule
  def fold_nhanzi!(node : BaseNode, succ = node.succ, prev : BaseNode? = nil) : BaseNode
    if time = fold_number_as_temporal(num: node, qti: succ, prev: prev)
      return time
    end

    case succ.key
    when "点"  then fold_nhanzi_dian!(node, succ, prev)
    when "分"  then fold_number_minute!(node, succ)
    when "分钟" then fold_number_minute!(node, succ, is_time: true)
    else           node
    end
  end

  def fold_nhanzi_dian!(node : BaseNode, succ : BaseNode, prev : BaseNode?) : BaseNode
    result = keep_pure_numeral?(succ.succ?)

    if result.is_a?(BaseNode)
      node.key = "#{node.key}#{succ.key}#{result.key}"
      node.val = "#{node.val} chấm #{result.val}" # TODO: correcting unit system
      return node.tap(&.fix_succ!(result.succ?))
    end

    prev || result ? fold_number_hour!(node, succ) : node
  end

  def keep_pure_numeral?(node : BaseNode?) : Bool | BaseNode
    return false unless node
    return true if node.key == "半" || node.key == "前后"
    return false unless node.numbers?
    return node unless succ = node.succ?
    succ.key == "分" || succ.key == "分钟" ? true : node
  end
end
