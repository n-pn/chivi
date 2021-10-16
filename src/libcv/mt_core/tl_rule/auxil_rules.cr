module CV::TlRule
  def heal_auxils!(node : MtNode, mode = 1) : MtNode
    case node.tag
    when .ule?  then node = heal_ule!(node)  # 了
    when .ude1? then node = heal_ude1!(node) # 的
    when .ude2? then node = heal_ude2!(node) # 地
    else             node
    end
  end

  def heal_ule!(node : MtNode) : MtNode
    return node unless (prev = node.prev?) && (succ = node.succ?)

    return node.heal!(val: "") if succ.tag.quoteop? || prev.tag.quotecl?
    return node.heal!(val: "") if prev.tag.quotecl? && !succ.tag.ends?

    return node if succ.tag.ends? || prev.tag.ends? || succ.key == prev.key
    return node if prev.tag.adjts? && prev.prev?(&.tag.ends?)

    node.heal!(val: "")
  end

  def heal_ude1!(node : MtNode) : MtNode
    puts node
    node.val = ""
    return node unless prev = node.prev?

    case prev
    when .popens?     then return node
    when prev.puncts? then return node.heal!("đích")
    when .names?, .propers?
      return node if (succ = node.succ?) && !succ.pstops?
    else
      # TODO: handle more case with prev
      return node
    end

    prev.prev? do |x|
      return node if x.verbs? || x.preposes? || x.nouns? || x.pronouns?
    end

    node.val = "của"
    fold_swap!(prev, node, PosTag::Dphrase, 9)
  end

  def heal_ude2!(node : MtNode) : MtNode
    return node if node.prev? { |x| x.tag.adjts? || x.tag.adverb? }
    return node if node.succ? { |x| x.verbs? || x.preposes? || x.concoord? }
    node.heal!(val: "địa", tag: PosTag::Noun)
  end

  def keep_ule?(prev : MtNode, node : MtNode, succ = node.succ?) : Bool
    return true unless succ
    return false if succ.popens?
    succ.ends? || succ.succ?(&.ule?) || false
  end
end
