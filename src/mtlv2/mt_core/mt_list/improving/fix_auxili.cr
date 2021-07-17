module CV::Improving
  def fix_ule!(node : MtNode) : MtNode
    return node unless (prev = node.prev) && (succ = node.succ)
    return node if succ.ends? || prev.ends? || succ.key == prev.key
    return node if prev.adjts? && prev.prev.try(&.ends?)
    node.update!(val: "")
  end

  def fix_ude2!(node : MtNode) : MtNode
    return node if !boundary?(node.succ) && node.prev.try(&.tag.adjts?)
    return node if !boundary?(node.prev) && node.succ.try(&.tag.verbs?)
    node.update!(val: "địa", tag: PosTag::Noun)
  end
end
