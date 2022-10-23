module MT::Core
  def fold_objt_prep!(objt : MtNode, prep : MonoNode)
    tag, pos = PosTag::PrepForm

    # FIXME: handle more type of preposes
    case prep.tag
    when .pre_bi3?
      prep.val = prep.prev?(&.adv_bu4?) ? "bằng" : "hơn"
      pos |= MtlPos::AtTail
    when .pre_ling?, .pre_gei3?
      prep.val = "làm" if prep.prev?(&.tag.content_words?)
    when .pre_zai?, .pre_cong?
      if objt.time_words? || objt.locale?
        prep.swap_val!
        pos |= MtlPos::AtTail
      end
    else
      prep.swap_val!
      pos |= MtlPos::AtTail if prep.at_tail?
    end

    PairNode.new(prep, objt, tag, pos, flip: false)
  end
end
