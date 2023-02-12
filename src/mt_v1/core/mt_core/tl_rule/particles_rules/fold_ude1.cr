module M1::TlRule
  # do not return left when fail to prevent infinity loop!
  def fold_ude1!(ude1 : MtNode,
                 prev = ude1.prev?, succ = ude1.succ?) : MtNode
    ude1.val = ""

    # ameba:disable Style/NegatedConditionsInUnless
    return ude1 unless prev && succ && !(prev.ends?)

    if (succ.pro_dems? || succ.pro_na2?) && (tail = succ.succ?)
      right = fold_pro_dems!(succ, tail)
    else
      right = scan_noun!(succ, mode: 3)
    end

    return ude1 unless right
    node = fold_ude1_left!(ude1: ude1, left: prev, right: right)
    fold_noun_after!(node)
  end

  # do not return left when fail to prevent infinity loop
  def fold_ude1_left!(ude1 : MtNode, left : MtNode, right : MtNode?) : MtNode
    return ude1 unless right && right.object?

    # puts [left, right]

    case left
    when .noun?, .human?, .nother?, .naffil?
      ude1.val = "của"
      flip = true
    else
      ude1.val = ""
      flip = !left.numeral?
    end

    left = fold!(left, ude1, tag: PosTag::DefnPhrase, dic: 2, flip: true)
    fold!(left, right, tag: PosTag::NounPhrase, dic: 6, flip: flip)
  end
end
