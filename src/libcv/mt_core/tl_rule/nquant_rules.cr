module CV::TlRule
  def nquant_is_complement?(node : MtNode) : Bool
    return false unless node.nquant?

    case node.key[-1]?
    when '次', '遍', '趟', '回', '声', '下', '把'
      true
    else
      false
    end
  end
end
