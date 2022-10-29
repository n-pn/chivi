module MT::Rules
  def fold_noun!(noun : MtNode)
    noun = make_noun_cons!(noun)
    # puts [noun, noun.prev?]

    # FIXME: since this only check for bond word, we can check for those exception in link_noun functon
    # thus no need to resolve mixedpos in this step
    prev = noun.prev
    prev = fix_mixedpos!(prev) if prev.mixedpos?
    noun = link_noun!(noun, junc: prev) if prev.bind_word?
    return noun if noun_is_modifier?(noun, prev)

    foldl_objt_full!(noun)
  end

  private def noun_is_modifier?(noun : MtNode, prev = noun.prev, succ = noun.succ) : Bool
    return true if prev.v_shi? && succ.ptcl_deps?
    return true if succ.adjt_words? && succ.succ?(&.ptcl_deps?)

    return false unless succ.tag.ptcl_dev? && (center = succ.succ?) && center.object?
    return false unless tail = center.succ?

    tail.verbal_words? || tail.adjt_words? || tail.ptcl_cmps?

    # FIXME:
    # - check if before prepos has subject or not
    # - check prepos and noun compatibility:
    #   + pre_zai take location/temporal
    #   + comparison prepos and comparision particles
    # - add more special
  end
end
