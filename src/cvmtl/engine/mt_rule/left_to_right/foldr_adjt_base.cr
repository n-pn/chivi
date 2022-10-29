module MT::Rules::LTR
  def foldr_adjt_base!(adjt : MtNode)
    tag, pos = PosTag.make(:amix)

    while succ = adjt.succ
      break unless succ.adjt_words? || succ.maybe_adjt?
      adjt = PairNode.new(adjt, succ, tag, pos, flip: false)
    end

    # FIXME: add suffix

    adjt
  end

  def foldr_advb_adjt(head : MonoNode, succ = head.succ)
    while succ.advb_words? || succ.maybe_advb?
      break if succ.maybe_adjt?
      succ = succ.succ
    end

    return unless succ.adjt_words? || succ.maybe_adjt?
    adjt = foldr_adjt_base!(succ)

    tag, pos = PosTag.make(:amix)

    while (prev = adjt.prev) && prev != head
      prev.as(MonoNode).fix_val! if prev.mixedpos?
      adjt = PairNode.new(prev, adjt, tag, pos, flip: prev.at_tail?)
    end

    head.fix_val! if head.mixedpos?
    PairNode.new(head, adjt, tag, pos, flip: head.at_tail?)
  end
end
