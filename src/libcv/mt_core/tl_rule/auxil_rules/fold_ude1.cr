module CV::TlRule
  # do not return left when fail to prevent infinity loop!
  def fold_ude1!(ude1 : MtNode, left = ude1.prev, right = ude1.succ?) : MtNode
    # puts [left, right]

    if left.pro_per? || (left.nominal? && !left.property?)
      head = fold!(left, ude1.set!("của"), PosTag::Naffil, dic: 7, flip: true)
    else
      head = fold!(left, ude1.set!(""), PosTag::DefnPhrase, dic: 7, flip: true)
    end

    return head unless right
    right = fold_once!(right)

    # puts [left, right, "fold_ude1"]

    if right.verb? || right.adjective?
      return head if left.subject?
    elsif !right.subject?
      return head
    end

    fold!(head, right, tag: right.tag, dic: 6, flip: true)
  end
end
