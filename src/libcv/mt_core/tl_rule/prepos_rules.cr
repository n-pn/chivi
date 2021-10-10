module CV::TlRule
  def heal_predui!(node : MtNode, succ = node.succ?) : MtNode
    return node.heal!("đúng", PosTag::Adjt) unless succ

    case succ.tag
    when .ude1?
      node.tag = PosTag::Adjt
      node.fold!(succ, "đúng")
    when .contws?, .quoteop?
      node.heal!("đối với")
    else
      node
    end
  end
end
