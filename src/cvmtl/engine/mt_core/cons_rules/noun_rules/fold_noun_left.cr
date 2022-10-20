module MT::Core
  def fold_noun!(noun : MtNode)
    noun = cons_noun!(noun)

    prev = noun.prev
    prev = fix_mixedpos!(prev) if prev.mixedpos?

    if prev.bond_word?
      noun = link_noun!(noun, junc: prev)
      prev = noun.prev
      prev = fix_mixedpos!(prev) if prev.mixedpos?
    end

    case prev
    when .preposes?
      make_prep_form!(noun: noun, prep: prev.as(MonoNode))
    when .verb_words?
      fold_noun_verb!(noun: noun, verb: prev)
    when .vcompl?
      prev = fold_cmpl!(prev)
      fold_noun_verb!(noun: noun, verb: prev)
    else
      noun
    end
  end

  private def noun_is_modifier?(noun : MtNode, prev = noun.prev, succ = noun.succ)
    return true if succ.adjt_words?
    return false unless succ.tag.pt_dev? && (center = succ.succ?) && center.object?
    return false unless tail = center.succ?

    tail.verb_words? || tail.adjt_words? || tail.pt_cmps?

    # FIXME:
    # - check if before prepos has subject or not
    # - check prepos and noun compatibility:
    #   + pre_zai take location/temporal
    #   + comparison prepos and comparision particles
    # - add more special
  end
end
