module MT::Rules
  def foldl_noun_full!(noun : MtNode)
    noun = foldl_noun_expr!(noun)
    # puts [noun, noun.prev?]

    # FIXME: since this only check for bond word, we can check for those exception in link_noun functon
    # thus no need to resolve mixedpos in this step
    prev = noun.prev
    prev = fix_mixedpos!(prev) if prev.mixedpos?

    if prev.join_word?
      noun = foldr_noun_join!(noun, junc: prev)
      prev = noun.prev
      prev = fix_mixedpos!(prev) if prev.mixedpos?
    end

    if noun.succ.ptcl_dep?
      return noun if noun_is_modifier?(noun, prev, noun.succ.succ)
      # elsif noun.succ.ptcl_dev?
    end

    foldl_objt_full!(noun)
  end

  private def noun_is_modifier?(noun : MtNode, prev = noun.prev, tail = noun.succ.succ) : Bool
    after_is_verb = after_is_verb?(tail)

    case prev
    when .v_shi?, .v_you?
      true
    when .verbal_words?
      (prev.vlinking? || prev.modal_verbs?) && after_is_verb
    when .preposes?
      !match_noun_prepos?(noun, prepos: prev, tail: tail, after_is_verb: after_is_verb)
    else
      false
    end

    # FIXME:
    # - check if before prepos has subject or not
    # - check prepos and noun compatibility:
    #   + pre_zai take location/temporal
    #   + comparison prepos and comparision particles
    # - add more special
  end

  def after_is_verb?(node : MtNode) : Bool
    return false unless succ = node.succ?
    return true if succ.verbal_words?
    succ.comma? && succ.succ?(&.verbal_words?) || false
  end
end
