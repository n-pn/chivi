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
    return node.set!("đúng", PosTag::Adjt) unless succ && !succ.ends?

    # TODO: combine grammar

    case succ.tag
    when .ude1?
      fold!(node.set!("đúng"), succ.set!(""), PosTag::Adjt, dic: 2)
    when .ule?
      succ.val = "" unless keep_ule?(node, succ)
      fold!(node.set!("đúng"), succ, PosTag::Adjt, dic: 2)
    when .ends?
      node.set!("đúng", PosTag::Adjt)
    when .contws?, .popens?
      node.set!("đối với")
    else
      node
    end
  end
end
