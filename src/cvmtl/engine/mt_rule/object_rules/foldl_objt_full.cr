module MT::Rules
  def foldl_objt_full!(objt : MtNode, prev = objt.prev)
    if prev.ptcl_dep?
      objt = foldl_objt_udep!(objt: objt, udep: prev)
      prev = objt.prev
    end

    if objt.succ.ptcl_dep?
      return objt unless can_fold_objt_prev?(objt, prev, objt.succ.succ)
      # elsif noun.succ.ptcl_dev?
    end

    prev = fix_mixedpos!(prev) if prev.mixedpos?
    # puts [objt, prev, "foldl_objt_full"]

    case prev
    when .preposes?
      foldl_objt_prep!(objt: objt, prep: prev.as(MonoNode))
    when .verbal_words?
      foldl_objt_verb!(objt: objt, verb: prev)
    else
      objt
    end
  end

  private def can_fold_objt_prev?(objt : MtNode, prev = objt.prev, tail = objt.succ.succ) : Bool
    # FIXME:
    # - check if before prepos has subject or not
    # - check prepos and objt compatibility:
    #   + pre_zai take location/temporal
    #   + comparison prepos and comparision particles
    # - add more special

    after_is_verb = after_is_verb?(tail)

    case prev
    when .v_shi?, .v_you?
      false
    when .verbal_words?
      match_objt_verbal?(objt, verbal: prev, tail: tail, after_is_verb: after_is_verb)
    when .preposes?
      match_objt_prepos?(objt, prepos: prev, tail: tail, after_is_verb: after_is_verb)
    else
      true
    end
  end

  def after_is_verb?(node : MtNode, succ = node.succ) : Bool
    succ = succ.succ if succ.comma?
    succ.verbal_words? || succ.preposes?
  end
end
