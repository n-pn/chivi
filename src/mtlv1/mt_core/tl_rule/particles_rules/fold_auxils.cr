module CV::TlRule
  def fold_auxils!(node : MtNode, mode = 1) : MtNode
    case node.tag
    when .pt_le?  then heal_ule!(node)  # 了
    when .pt_dep? then fold_ude1!(node) # 的
    when .SPACE
      heal_ude2!(node)                  # 地
    when .pt_der? then heal_ude3!(node) # 得
    when .usuo?   then fold_usuo!(node) # 所
    else               node
    end
  end

  def heal_ule!(node : MtNode, prev = node.prev?, succ = node.succ?) : MtNode
    return node unless prev && succ

    case
    when prev.boundary?, succ.boundary?, succ.key == prev.key
      node.set!("rồi")
    else
      node.set!("")
    end
  end

  def heal_ude2!(node : MtNode) : MtNode
    return node if node.prev? { |x| x.tag.adjts? || x.tag.adverb? }
    return node unless succ = node.succ?
    return node.set!("đất", PosTag::Noun) if succ.v_shi? || succ.v_you?
    return node if succ.verbal? || succ.preposes? || succ.concoord?
    node.set!(val: "địa", tag: PosTag::Noun)
  end

  def fold_verb_ule!(verb : MtNode, node : MtNode, succ = node.succ?)
    if succ && !(succ.boundary? || succ.succ?(&.pt_le?))
      node.val = ""
    end

    if succ && succ.key == verb.key
      node = succ
    end

    fold!(verb, node, PosTag::Verb, dic: 5)
  end

  def keep_pt_le?(prev : MtNode, node : MtNode, succ = node.succ?) : Bool
    return true unless succ
    return false if succ.pstart?
    succ.boundary? || succ.succ?(&.pt_le?) || false
  end
end
