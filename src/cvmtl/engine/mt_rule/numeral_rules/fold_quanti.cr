module MT::Rules
  def fold_quanti!(quanti : MtNode, prev = quanti.prev) : MtNode
    if quanti.qt_ge4? && quanti.is_a?(MonoNode) && quanti.succ.noun_words?
      quanti.val = ""
      quanti.pos |= MtlPos.flags(CapRelay, NoSpaceL, NoSpaceR, Skipover)
    end

    tag = quanti.tag.qt_to_nq
    pos = MtlPos.flags(Object)

    return fold_quanti_number!(quanti, number: prev, tag: tag, pos: pos) if prev.numbers?
    return quanti unless prev.quantis? && prev.is_a?(MonoNode)

    pos |= MtlPos.flags(MaybeAdvb)

    if (head = prev.prev?) && head.num_yi1?
      head = head.as(MonoNode)
      head.val = "từng #{prev.val}"
      TrioNode.new(head, prev, quanti, tag, pos)
    else
      prev.val = "từng"
      PairNode.new(prev, quanti, tag, pos)
    end
  end

  def fold_quanti_number!(quanti : MtNode, number : MtNode, tag : MtlTag, pos : MtlPos)
    return quanti if number.ordinal?

    nquant = PairNode.new(number, quanti, tag, pos)

    prev = quanti.prev
    return nquant unless (head = prev.prev?) && number.num_yi1? && prev.quantis? && head.num_yi1?

    number.as(MonoNode).val = "từng"
    head.as(MonoNode).val = "từng"

    redup = PairNode.new(head, prev, tag, pos)
    pos |= MtlPos.flags(MaybeAdvb)

    PairNode.new(redup, nquant, tag, pos)
  end
end
