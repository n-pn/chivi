module MT::Core
  def fold_adjt_bu4!(adjt : MtNode, bu4 = adjt.prev, prev = bu4.prev)
    tag, pos = PosTag.make(:aform)

    if (prev.adjt_words? || prev.maybe_adjt?) && (head = prev.prev) && head.tag.adv_bu4?
      prev = PairNode.new(head, prev, tag, pos)
      adjt = PairNode.new(bu4, adjt, tag, pos)
      return PairNode.new(prev, adjt, tag, pos)
    end

    unless adjt.is_a?(MonoNode) && prev.is_a?(MonoNode) && adjt.key == prev.key
      return PairNode.new(bu4, adjt, tag, pos)
    end

    prev.as(MonoNode).val = "hay"
    prev = PairNode.new(prev, bu4, flip: true)

    PairNode.new(prev, adjt, tag, pos, flip: true)
  end
end
