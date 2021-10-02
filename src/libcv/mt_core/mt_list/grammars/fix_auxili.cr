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
    if node.prev?(&.tag.quoteop?) && node.succ?(&.tag.quotecl?)
      return node.update!(val: "của")
    end

    unless mode > 1 && boundary?(node.succ?)
      return node.update!(val: "")
    end

    prev = node.prev.not_nil!

    if prev.tag.names? || prev.tag.propers?
      unless prev.prev?(&.tag.verbs?) || prev.prev?(&.tag.prepos?)
        node.val = "của"
        node.dic = 9
        return node.tap(&.fuse_left!("", " #{prev.val}"))
      end
    end

    node.update!(val: "")
  end
end
