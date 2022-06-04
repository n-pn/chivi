module CV::TlRule
  # do not return left when fail to prevent infinity loop!
  def fold_ude1!(ude1 : MtNode, left = ude1.prev, right : MtNode? = nil) : MtNode
    # puts [left, right]

    if left.pro_per? || (left.nominal? && !left.property? && !left.temporal?)
      head = fold!(left, ude1.set!("của"), PosTag::Naffil, dic: 7, flip: true)
    else
      head = fold!(left, ude1.set!(""), PosTag::DefnPhrase, dic: 7, flip: true)
    end

    unless right
      return head unless right = ude1.succ?
      right = fold_once!(right)

      if right.verb? || right.adjective?
        return head if left.subject?
      elsif !right.subject?
        return head
      end
    end

    # puts [left, right, "fold_ude1"]

    fold!(head, right, tag: right.tag, dic: 6, flip: true)
  end
end
