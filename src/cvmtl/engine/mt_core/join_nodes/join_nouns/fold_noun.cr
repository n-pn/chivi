module MT::Core
  def fold_noun!(noun : MtNode, prev = noun.prev)
    if prev.is_a?(MonoNode) && prev.mixedpos?
      prev = fix_mixedpos!(prev)
    end

    return noun if noun_is_modifier?(noun, prev)

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

  def fold_noun_verb!(noun : MtNode, verb : MtNode)
    verb = fold_verb!(verb) if verb.is_a?(MonoNode)

    case verb
    when VerbForm
      form = verb
    when PairNode
      raise "unexpected #{verb}" unless verb.tag.subj_verb?

      subj = verb
      form = verb.tail
      form = VerbForm.new(form) unless form.is_a?(VerbForm)
    else
      form = VerbForm.new(verb)
    end

    if subj
      subj.fix_succ!(noun.succ?)
      noun.fix_succ!(nil)
    end

    form.add_objt(noun)
    form
  end

  private def noun_is_modifier?(noun : MtNode, prev = noun.prev)
    return false unless (succ = noun.succ?) && succ.tag.pt_dev?
    return false unless (center = succ.succ?) && center.object?
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
