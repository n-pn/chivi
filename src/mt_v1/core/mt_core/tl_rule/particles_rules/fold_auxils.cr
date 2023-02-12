module M1::TlRule
  def fold_auxils!(node : MtNode, mode = 1) : MtNode
    case node.tag
    when .ule?  then heal_ule!(node)  # 了
    when .ude1? then fold_ude1!(node) # 的
    when .ude2? then heal_ude2!(node) # 地
    when .ude3? then heal_ude3!(node) # 得
    when .usuo? then fold_usuo!(node) # 所
    else             node
    end
  end

  def heal_ule!(node : MtNode, prev = node.prev?, succ = node.succ?) : MtNode
    return node unless prev && succ

    case
    when prev.ends?, succ.ends?, succ.key == prev.key
      node.set!("rồi")
    else
      node.set!("")
    end
  end

  def heal_ude2!(node : MtNode) : MtNode
    return node if node.prev? { |x| x.tag.adjective? || x.tag.adverb? }
    return node unless succ = node.succ?
    return node.set!("đất", PosTag::Noun) if succ.v_shi? || succ.v_you?
    return node if succ.verbal? || succ.preposes? || succ.concoord?
    node.set!(val: "địa", tag: PosTag::Noun)
  end

  def fold_verb_ule!(verb : MtNode, node : MtNode, succ = node.succ?)
    if succ && !(succ.ends? || succ.succ?(&.ule?))
      node.val = ""
    end

    if succ && succ.key == verb.key
      node = succ
    end

    fold!(verb, node, PosTag::Verb, dic: 5)
  end

  def keep_ule?(prev : MtNode, node : MtNode, succ = node.succ?) : Bool
    return true unless succ
    return false if succ.popens?
    succ.ends? || succ.succ?(&.ule?) || false
  end
end
