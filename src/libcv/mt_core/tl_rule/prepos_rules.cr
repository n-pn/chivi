module CV::TlRule
  def fold_preposes!(node : MtNode, succ = node.succ?) : MtNode
    return node unless succ

    # TODO!
    case node.tag
    when .pre_dui? then fold_pre_dui!(node, succ)
    when .pre_bei? then fold_pre_bei!(node, succ)
    when .pre_zai? then fold_pre_zai!(node, succ)
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
    when .ends?, .conjunct?, .concoord?
      node.set!("đúng", PosTag::Adjt)
    when .contws?, .popens?
      node.set!("đối với")
    else
      node
    end
  end

  def fold_pre_bei!(node : MtNode, succ = node.succ?) : MtNode
    return node unless succ && succ.verb?
    # todo: change "bị" to "được" if suitable
    node = fold!(node, succ, succ.tag, dic: 5)
    fold_verbs!(node)
  end

  def fold_pre_zai!(node : MtNode, succ = node.succ?) : MtNode
    return node unless succ && succ.nouns?

    succ = fold_noun!(succ)
    if (succ_2 = succ.succ?) && succ_2.space?
      succ = fold_noun_space!(succ, succ_2)
    end

    # puts [node, succ, succ.succ?]
    return node unless succ.succ?(&.ude1?)

    node.val = "ở"

    if (prev = node.prev?) && prev.verbs?
      node = prev
    end

    fold!(node, succ, PosTag::Dphrase, dic: 9)
  end
end
