module CV::MTL::Grammars
  def fix_ule!(node : MtNode) : MtNode
    return node unless (prev = node.prev?) && (succ = node.succ?)

    return node.update!(val: "") if succ.tag.quoteop? || prev.tag.quotecl?
    return node.update!(val: "") if prev.tag.quotecl? && !succ.tag.ends?

    return node if succ.tag.ends? || prev.tag.ends? || succ.key == prev.key
    return node if prev.tag.adjts? && prev.prev?(&.tag.ends?)

    node.update!(val: "")
  end

  def fix_ude2!(node : MtNode) : MtNode
    return node if node.prev? { |x| x.tag.adjts? || x.tag.adverb? }
    return node if node.succ? { |x| x.verbs? || x.preposes? || x.concoord? }
    node.update!(val: "địa", tag: PosTag::Noun)
  end

  def fix_ude1!(node : MtNode, mode = 1) : MtNode
    return node unless prev = node.prev?
    return node if prev.puncts?

    node.val = ""

    return node unless node.succ?(&.endsts?)
    return node unless prev.tag.nouns? || prev.tag.propers?

    unless prev.prev?(&.tag.verbs?) || prev.prev?(&.tag.preposes?)
      return prev.fold!(node, "của #{prev.val}", dic: 7)
    end

    node
  end
end
