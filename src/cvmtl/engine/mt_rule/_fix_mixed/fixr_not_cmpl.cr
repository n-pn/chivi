module MT::Rules
  extend self

  def fixr_not_cmpl!(head : MonoNode)
    head
    # case head
    # when .loc_zhong?
    #   head.tap(&.pos = head.pos & ~MtlPos::MaybeCmpl)
    # when .loc_shang?, .loc_xia?
    #   fixr_shangxia!(head)
    # else
    #   head.tag, head.pos = PosTag.not_vcompl(head.key)
    #   head
    # end
  end
end
