module MT::Core
  def fold_noun!(noun : MtNode, prev : MtNode)
    prev = fix_uniqword!(prev) if prev.uniqword?
    return noun if noun_is_modifier?(noun, prev)

    prev = fold_cmpl!(prev) if prev.vcompl?

    case prev
    when .preposes?   then fold_prep_form!(noun: noun, verb: prev)
    when .verb_words? then fold_noun_verb!(noun: noun, prep: prev)
    else                   noun
    end
  end

  def fold_noun_verb!(noun : MtNode, verb : MtNode)
    prev = fold_verb!(verb)

    case prev
    when VerbForm then form = prev
    when .subj_verb?
      form = prev.as(PairNode).tail
      form = VerbForm.new(form) unless form.is_a?(VerbForm)
    end

    form.add_objt(noun)
    form
  end

  def fold_prep_form!(noun : MtNode, prep : MtNode)
    tag, pos = PosTag::PrepForm

    # FIXME: handle more type of preposes
    case prep.tag
    when .pre_ling?, .pre_gei3?
      prep.val = "làm" if prep.prev(&.content?)
    else
      prev.swap_val!
      pos |= MtlPos::AtTail if prev.at_tail?
    end

    PairNode.new(prep, noun, tag, pos, flip: pos.at_tail?)
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
