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
    when .ude1?, .ule?
      node.tag = PosTag::Adjt
      node.fold!(succ, "đúng")
    when .contws?, .quoteop?
      node.heal!("đối với")
    else
      node
    end
  end
end
