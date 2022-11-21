module MT::Rules
  def foldl_udep_base!(udep : MtNode, head = udep.head)
    raise "udep should be MonoNode" unless udep.is_a?(MonoNode)

    head = foldl_once!(head)
    return udep if head.unreal?

    tag = MtlTag::DcPhrase
    pos = MtlPos::AtTail

    if head.ktetic?
      udep.val = "của"
    else
      udep.skipover!
    end

    PairNode.new(head, udep, tag, pos, flip: true)
  end
end
