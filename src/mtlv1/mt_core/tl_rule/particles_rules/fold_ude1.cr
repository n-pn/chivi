module CV::TlRule
  # do not return left when fail to prevent infinity loop!
  def fold_ude1!(ude1 : BaseNode, prev = ude1.prev?, succ = ude1.succ?) : BaseNode
    ude1.val = ""

    # ameba:disable Style/NegatedConditionsInUnless
    return ude1 unless prev && succ && !(prev.boundary?)

    right = scan_noun!(succ, mode: 3)

    return ude1 unless right
    node = fold_ude1_left!(ude1: ude1, left: prev, right: right)
    fold_noun_after!(node)
  end

  # do not return left when fail to prevent infinity loop
  def fold_ude1_left!(ude1 : BaseNode, left : BaseNode, right : BaseNode?) : BaseNode
    case right
    when nil then return ude1
    when .vobjs?
      right.tag = PosTag::Nform
    else
      return ude1 unless right.nounish?
    end

    # puts [left, right]

    if left.ktetic?
      ude1.val = "của"
      ptag = PosTag::DgPhrase
    else
      ude1.as(MtTerm).empty!(true)
      ptag = PosTag::DcPhrase
    end

    left = fold!(left, ude1, tag: ptag, dic: 2, flip: true)
    fold!(left, right, tag: right.tag, dic: 6, flip: true)
  end
end
