module MT::Rules
  def foldl_objt_prep!(objt : MtNode, prep : MonoNode)
    tag, pos = PosTag.make(:prep_form)

    # FIXME: handle more type of preposes
    case prep.tag
    when .prep_bi3?
      prep.val = prep.prev?(&.adv_bu4?) ? "bằng" : "hơn"
      pos |= MtlPos::AtTail
    when .prep_gei3?
      prep.val = "cho" if prep.prev?(&.unreal?.!)
      pos |= MtlPos::AtTail if objt.humankind?
    when .prep_ling?
      prep.val = "làm" if prep.prev?(&.unreal?.!)
    when .prep_zai?, .prep_cong?
      if objt.all_times? || objt.spaceword?
        prep.fix_val!
        pos |= MtlPos::AtTail
      end
    when .prep_rang?
      fix_prep_rang_val!(prep, objt)
    else
      prep.fix_val!
      pos |= MtlPos::AtTail if prep.at_tail?
    end

    return PairNode.new(prep, objt, tag, pos, flip: false) if objt.succ?(&.verbal_words?)

    expr = VerbExpr.new(prep.as_verb!)
    expr.add_objt(objt)

    while prev = expr.prev?
      break unless prev.advb_words? || prev.maybe_advb?
      expr.add_advb(prev)
    end

    expr
  end

  def fix_prep_rang_val!(prep : MonoNode, objt : MtNode) : Nil
    case
    when prep.prev? { |x| x.advb_words? || x.maybe_auxi? }
      prep.val = "để cho"
    when objt.succ?(&.verbal_words?)
      prep.val = "làm cho"
    else
      prep.val = "khiến cho"
    end
  end
end
