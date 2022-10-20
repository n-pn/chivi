module MT::Core
  def join_udep!(udep : MtNode)
    raise "udep should be MonoNode" unless udep.is_a?(MonoNode)

    tag = MtlTag::DcPhrase
    pos = MtlPos::AtTail

    head = fold_left!(udep.prev)

    if head.ktetic?
      udep.val = "của"
    else
      udep.inactivate!
    end

    PairNode.new(head, udep, tag, pos, flip: true)
  end
end
