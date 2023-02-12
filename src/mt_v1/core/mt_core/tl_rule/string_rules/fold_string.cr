module M1::TlRule
  def fold_strings!(node : MtNode) : MtNode
    if node.litstr?
      fold_litstr!(node)
    elsif node.urlstr?
      fold_urlstr!(node)
    else
      node
    end
  end
end
