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

  def fold!(head : MtNode, tail : MtNode,
            tag : PosTag = PosTag::None, dic : Int32 = 9,
            swap : Bool = false)
    # Create new common root
    root = MtNode.new("", "", tag, dic, swap ? tail.idx : head.idx)

    if swap
      root.set_body!(tail)
      head.fix_root!(nil)
    else
      root.set_body!(head)
    end

    root.fix_prev!(head.prev?)
    root.fix_succ!(tail.succ?)

    if swap
      # check if there is some node in between
      # if there is then swap their prev and succ node to current head and tail
      if tail != head.succ?
        tail.fix_succ!(head.succ?)
        head.fix_prev!(tail.prev?)
      else
        tail.fix_succ!(head)
      end

      tail.fix_prev!(nil)
      head.fix_succ!(nil)
    else
      head.fix_prev!(nil)
      tail.fix_succ!(nil)
    end

    root
  end

  # def fold_swap!(tail : MtNode, head : MtNode, tag = PosTag::Unkn, dic = 9)
  #   root = MtNode.new("", "", tag, dic, head.idx)
  #   root.body = head

  #   root.fix_root!(tail.root?)
  #   tail.fix_root!(nil)
  #   head.root = root

  #   if prev = tail.prev?
  #     prev.succ = root
  #     root.prev = prev
  #   else
  #     root.fix_prev!(nil)
  #   end

  #   if succ = head.succ?
  #     succ.prev = root
  #     root.succ = succ
  #   else
  #     root.fix_succ!(nil)
  #   end

  #   # check if there is some node in between
  #   # if there is then swap their prev and succ node to current head and tail
  #   if head != tail.succ?
  #     if succ = tail.succ?
  #       head.succ = succ
  #       succ.prev = head
  #     end

  #     if prev = head.prev?
  #       tail.prev = prev
  #       prev.succ = tail
  #     end
  #   else
  #     head.fix_succ!(tail)
  #   end

  #   head.fix_prev!(nil)
  #   tail.fix_succ!(nil)

  #   root
  # end
end
