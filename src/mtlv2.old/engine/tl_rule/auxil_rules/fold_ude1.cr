module MtlV2::TlRule
  # do not return left when fail to prevent infinity loop!
  def fold_ude1!(ude1 : BaseNode, left = ude1.prev, right : BaseNode? = nil) : BaseNode
    # puts [left, right]

    if is_tangible?(left)
      head = fold!(left, ude1.set!("của"), PosTag::Naffil, dic: 7, flip: true)
    else
      head = fold!(left, ude1.set!(""), PosTag::DefnPhrase, dic: 7, flip: true)
    end

    unless right
      return head unless right = head.succ?
      # puts [right]

      right = fold_once!(right)

      if right.verb? || right.adjective?
        return head if left.subject?
      elsif !right.subject?
        # ude1.val = "cái" if left.verbal?
        return head
      end
    end

    # puts [left, right, "fold_ude1"]

    fold!(head, right, tag: right.tag, dic: 6, flip: true)
  end

  def is_tangible?(node : BaseNode)
    return node.pro_per? unless node.noun_words?
    !(node.property? || node.ntime? || node.nqtime?)
  end
end
