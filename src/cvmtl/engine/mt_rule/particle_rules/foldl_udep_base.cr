module MT::Rules
  def foldl_udep_base!(udep : MtNode)
    raise "udep should be MonoNode" unless udep.is_a?(MonoNode)

    tag = MtlTag::DcPhrase
    pos = MtlPos::AtTail

    head = foldl_once!(udep.prev)

    if head.ktetic?
      udep.val = "của"
    else
      udep.skipover!
    end

    PairNode.new(head, udep, tag, pos, flip: true)
  end
end
