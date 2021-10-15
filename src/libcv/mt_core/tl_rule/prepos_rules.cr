module CV::TlRule
  def fold_preposes!(node : MtNode, succ = node.succ?) : MtNode
    return node unless succ

    # TODO!
    case node.tag
    when .pre_dui? then fold_pre_dui!(node, succ)
    else                node
    end
  end

  def fold_pre_dui!(node : MtNode, succ = node.succ?) : MtNode
    return node.heal!("đúng", PosTag::Adjt) unless succ && !succ.ends?

    # TODO: combine grammar

    case succ.tag
    when .ude1?
      node.val = "đúng"
      succ.val = ""
      fold!(node, succ, PosTag::Adjt, 3)
    when .ule?
      node.val = "đúng"
      succ.val = "" unless keep_ule?(node, succ)

      fold!(node, succ, PosTag::Adjt, 3)
    when .contws?, .quoteop?, .parenop?, .brackop?, .titleop?
      node.heal!("đối với")
    else
      node
    end
  end
end
