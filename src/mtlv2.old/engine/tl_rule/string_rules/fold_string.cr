module MtlV2::TlRule
  def fold_strings!(node : BaseNode) : BaseNode
    if node.litstr?
      fold_litstr!(node)
    elsif node.urlstr?
      fold_urlstr!(node)
    else
      node
    end
  end
end
