module CV::TlRule
  extend self

  def end_sentence?(node : Nil)
    true
  end

  def end_sentence?(node : MtNode)
    node.pstops?
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

    root.fix_root!(head.root?)
    head.root = root

    if prev = head.prev?
      prev.succ = root
      root.prev = prev
    else
      root.fix_prev!(nil)
    end

    if succ = tail.succ?
      succ.prev = root
      root.succ = succ
    else
      root.fix_succ!(nil)
    end

    head.fix_prev!(nil)
    tail.fix_succ!(nil)

    root
  end

  def fold_swap!(tail : MtNode, head : MtNode, tag = PosTag::Unkn, dic = 9)
    # return fold!(tail, head, tag, dic)

    root = MtNode.new("", "", tag, dic, head.idx)
    root.body = head

    root.fix_root!(tail.root?)
    tail.fix_root!(nil)
    head.root = root

    if prev = tail.prev?
      prev.succ = root
      root.prev = prev
    else
      root.fix_prev!(nil)
    end

    if succ = head.succ?
      succ.prev = root
      root.succ = succ
    else
      root.fix_succ!(nil)
    end

    # check if there is some node in between
    # if there is then swap their prev and succ node to current head and tail
    if head != tail.succ?
      if succ = tail.succ?
        head.succ = succ
        succ.prev = head
      end

      if prev = head.prev?
        tail.prev = prev
        prev.succ = tail
      end
    else
      head.succ = tail
      tail.prev = head
    end

    head.fix_prev!(nil)
    tail.fix_succ!(nil)

    root
  end
end
