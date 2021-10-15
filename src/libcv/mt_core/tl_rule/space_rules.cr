module CV::TlRule
  def fold_noun_space!(node : MtNode, succ = node.succ?) : MtNode
    return node unless succ
    node.tag = PosTag::Place

    case succ.tag
    when .vshang?
      succ.val = "trên"
    when .vxia?
      succ.val = "dưới"

      node.fold!("dưới #{node.val}")
    else
      succ.val = "trước" if succ.key == "之前"
    end

    fold_swap!(node, succ, PosTag::Place, 3)
  end
end
