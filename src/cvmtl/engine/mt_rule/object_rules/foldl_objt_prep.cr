module MT::Rules
  def foldl_objt_prep!(objt : MtNode, prep : MonoNode)
    tag, pos = PosTag.make(:prep_form)

    # FIXME: handle more type of preposes
    case prep.tag
    when .prep_bi3?
      prep.val = prep.prev?(&.adv_bu4?) ? "bằng" : "hơn"
      pos |= MtlPos::AtTail
    when .prep_ling?, .prep_gei3?
      prep.val = "làm" if prep.prev?(&.unreal?.!)
    when .prep_zai?, .prep_cong?
      if objt.all_times? || objt.spaceword?
        prep.fix_val!
        pos |= MtlPos::AtTail
      end
    else
      prep.fix_val!
      pos |= MtlPos::AtTail if prep.at_tail?
    end

    PairNode.new(prep, objt, tag, pos, flip: false)
  end
end
