module CV::TlRule
  extend self

  def end_sentence?(node : Nil)
    true
  end

  def end_sentence?(node : MtNode)
    node.endsts?
  end

  def boundary?(node : Nil)
    true
  end

  def boundary?(node : MtNode)
    node == node.tag.none? || node.tag.puncts? || node.tag.interjection?
  end

  def fold!(head : MtNode, tail : MtNode, tag = PosTag::None, dic = 4)
    root = MtNode.new("", "", tag, dic, head.idx)
    root.body = head

    root.fix_prev!(head.prev?)
    head.fix_prev!(nil)

    root.fix_succ!(tail.succ?)
    tail.fix_succ!(nil)

    root
  end

  def swap!(left : MtNode, right : MtNode)
    succ = right.succ?
    right.fix_prev!(left.prev?)
    right.fix_succ!(left)
    left.fix_succ!(succ)

    {right, left}
  end

  def swap!(left : MtNode, middle : MtNode, right : MtNode)
    left, right = swap!(left, right)
    middle.fix_prev!(left)
    middle.fix_succ!(right)
    {left, right}
  end
end
