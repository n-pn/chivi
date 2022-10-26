module MT::Core::Step0
  def fuse_number!(number : MonoNode)
    return number if number.ordinal?

    quanti = number.succ.as(MonoNode)
    quanti = fix_qttemp!(quanti, prev: number) if quanti.maybe_quanti?

    return number unless quanti.quantis?
    return make_nquant!(number, quanti) unless number.num_yi1?

    # handle reduplication

    redup_head = quanti.succ.as(MonoNode)

    if redup_head.key == quanti.key
      number.val = "từng"
      redup_head.val = "một"

      tag = quanti.tag.qt_to_nq
      pos = PosTag.map_pos(tag) | MtlPos::MaybeAdvb

      TrioNode.new(number, quanti, redup_head, tag, pos)
    elsif redup_head.num_yi1? && (redup_tail = redup_head.succ.as(MonoNode)) && redup_tail.key == quanti.key
      number.val = "từng"
      redup_head.val = "từng"

      tag = quanti.tag.qt_to_nq
      pos = PosTag.map_pos(tag)

      head = PairNode.new(number, quanti, tag, pos)
      tail = PairNode.new(redup_head, redup_tail, tag, pos)

      PairNode.new(head, tail, tag, pos | MtlPos::MaybeAdvb)
    else
      make_nquant!(number, quanti)
    end
  end

  def make_nquant!(number : MonoNode, quanti : MonoNode)
    tag = quanti.tag.qt_to_nq
    pos = PosTag.map_pos(tag)

    # FIXME: handle temporal expression here

    PairNode.new(number, quanti, tag, pos)
  end
end
