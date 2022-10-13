module MT::TlRule
  def fold_auxils!(node : MtNode, mode = 1) : MtNode
    case node.tag
    when .pt_le?  then heal_ule!(node)  # 了
    when .pt_dep? then fold_ude1!(node) # 的
    when .pt_dev? then heal_ude2!(node) # 地
    when .pt_der? then heal_ude3!(node) # 得
    when .pt_suo? then fold_usuo!(node) # 所
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
    return node if node.prev? { |x| x.tag.adjt_words? || x.tag.advb_words? }
    return node unless succ = node.succ?
    return node.set!("đất", PosTag::Nword) if succ.v_shi? || succ.v_you?
    return node if succ.verb_words? || succ.preposes? || succ.concoord?
    node.set!(val: "địa", tag: PosTag::Nword)
  end

  def fold_verb_ule!(verb : MtNode, node : MtNode, succ = node.succ?)
    if succ && !(succ.boundary? || succ.succ?(&.pt_le?))
      node.val = ""
    end

    if succ && succ.key == verb.key
      node = succ
    end

    fold!(verb, node, PosTag::Verb)
  end

  def keep_pt_le?(prev : MtNode, node : MtNode, succ = node.succ?) : Bool
    return true unless succ
    return false if succ.start_puncts?
    succ.boundary? || succ.succ?(&.pt_le?) || false
  end
end
