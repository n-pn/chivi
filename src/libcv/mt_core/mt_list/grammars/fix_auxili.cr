module CV::MTL::Grammars
  def fix_ule!(node : MtNode) : MtNode
    return node unless (prev = node.prev) && (succ = node.succ)
    return node.update!(val: "") if succ.quoteop? || prev.quotecl?
    return node.update!(val: "") if prev.quotecl? && !succ.ends?

    return node if succ.ends? || prev.ends? || succ.key == prev.key
    return node if prev.adjts? && prev.prev.try(&.ends?)

    node.update!(val: "")
  end

  def fix_ude2!(node : MtNode) : MtNode
    return node if node.prev.try { |x| x.adjts? || x.adverb? }
    return node if node.succ.try { |x| x.verbs? || x.preposes? || x.conjuncts? }
    node.update!(val: "địa", tag: PosTag::Noun)
  end

  def fix_ude1!(node : MtNode, mode = 1) : MtNode
    if node.prev.try(&.quoteop?) && node.succ.try(&.quotecl?)
      return node.update!(val: "của")
    end

    unless mode > 1 && boundary?(node.succ)
      return node.update!(val: "")
    end

    prev = node.prev.not_nil!

    if prev.names? || prev.propers?
      unless prev.prev.try(&.verbs?) || prev.prev.try(&.prepos?)
        node.val = "của"
        node.dic = 9
        return node.tap(&.fuse_left!("", " #{prev.val}"))
      end
    end

    node.update!(val: "")
  end
end
