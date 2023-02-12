module M1::TlRule
  extend self

  def fold!(head : MtNode, tail : MtNode,
            tag : PosTag = PosTag::Unkn, dic : Int32 = 9,
            flip : Bool = false)
    MtList.new(head, tail, tag, dic, idx: head.idx, flip: flip)
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
    node.tag.none? || node.tag.pstops? || node.tag.exclam?
  end
end
