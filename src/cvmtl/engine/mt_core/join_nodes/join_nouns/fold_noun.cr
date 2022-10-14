module MT::Core
  def fold_noun!(noun : MtNode, prev : MtNode)
    prev = fix_uniqword!(prev) if prev.uniqword?

    case prev
    when .vcompl?     then fold_noun_cmpl!(noun, prev)
    when .preposes?   then fold_prep_form!(noun, prev)
    when .verb_words? then fold_noun_verb!(noun, prev)
    else                   noun
    end
  end

  def fold_noun_cmpl!(noun : MtNode, cmpl : MtNode)
    verb = fold_cmlp!(cmpl)
    fold_noun_verb!(noun, verb)
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
    return noun unless is_prep_form?(prep, noun)

    tag, pos = PosTag::PrepForm

    # FIXME: handle more type of preposes
    case prep.tag
    when .pre_zi4?
      prep.val = "từ"
    when .pre_rang?
      prep.val = "khiến"
    when .pre_ling?
      prep.val = "làm" if prep.prev.content?
    when .pre_gei3?
      prep.val = "làm" if prep.prev.content?
    when .pre_dui?
      prep.val = "với"
      pos |= MtlPos::AtTail
    else
      prev.swap_val!
      pos |= MtlPos::AtTail if prev.at_tail?
    end

    PairNode.new(prep, noun, tag, pos, flip: pos.at_tail?)
  end

  private def is_prep_form?(prep : MtNode, noun : MtNode)
    # FIXME:
    # - check if before prepos has subject or not
    # - check prepos and noun compatibility:
    #   + pre_zai take location/temporal
    #   + comparison prepos and comparision particles
    # - add more special

    return true unless (succ = noun.succ?) && succ.tag.pt_dev?
    return true unless (center = succ.succ?) && center.object?
    return true unless tail = center.succ?

    return false if tail.common_verbs?
    !prep.pos.compare? && !(tail.adjt_words? || tail.pt_cmps?)
  end
end
