module CV::TlRule
  def fold_noun_space!(node : MtNode, succ = node.succ?) : MtNode
    return node unless succ
    node.tag = PosTag::Place

    case succ.tag
    when .vshang?
      node.fold!("trên #{node.val}")
    when .vxia?
      node.fold!("dưới #{node.val}")
    else
      val = succ.key == "之前" ? "trước" : succ.val
      node.fold!("#{val} #{node.val}")
    end
  end
end
