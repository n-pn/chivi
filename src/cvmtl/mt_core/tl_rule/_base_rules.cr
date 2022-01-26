module CV::TlRule
  extend self

  def fold!(head : MtNode, tail : MtNode,
            tag : PosTag = PosTag::None, dic : Int32 = 9,
            flip : Bool = false)
    # Create new common root
    root = MtNode.new("", "", tag, dic, head.idx)

    if flip
      root.set_body!(tail)
      head.fix_root!(nil)
    else
      root.set_body!(head)
    end

    root.fix_prev!(head.prev?)
    root.fix_succ!(tail.succ?)

    if flip
      # check if there is some node in between
      # if there is then flip their prev and succ node to current head and tail
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

  def cast_noun!(node : MtNode)
    MtDict::REFINE_NOUNS[node.key]?.try { |val| node.val = val }
    node.set!(PosTag::Noun)
  end

  def cast_verb!(node : MtNode)
    MtDict::REFINE_VERBS[node.key]?.try { |val| node.val = val }
    node.set!(PosTag::Verb)
  end

  def cast_adjt!(node : MtNode)
    MtDict::REFINE_ADJTS[node.key]?.try { |val| node.val = val }
    node.set!(PosTag::Adjt)
  end

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
    node == node.tag.none? || node.tag.puncts? || node.tag.exclam?
  end
end
