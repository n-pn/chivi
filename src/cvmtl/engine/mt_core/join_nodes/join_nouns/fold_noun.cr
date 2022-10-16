module MT::Core
  def fold_noun!(noun : MtNode, prev = noun.prev)
    prev = fix_uniqword!(prev.as(MonoNode)) if prev.uniqword?
    return noun if noun_is_modifier?(noun, prev)

    prev = fold_cmpl!(prev) if prev.vcompl?

    case prev
    when .preposes?   then fold_prep_form!(noun: noun, prep: prev.as(MonoNode))
    when .verb_words? then fold_noun_verb!(noun: noun, verb: prev)
    else                   noun
    end
  end

  def fold_noun_verb!(noun : MtNode, verb : MtNode)
    prev = join_verb!(verb)

    case prev
    when VerbForm then form = prev
    when .subj_verb?
      form = prev.as(PairNode).tail
      form = VerbForm.new(form) unless form.is_a?(VerbForm)
    else
      form = VerbForm.new(prev)
    end

    form.add_objt(noun)
    form
  end

  def fold_prep_form!(noun : MtNode, prep : MonoNode)
    tag, pos = PosTag::PrepForm

    # FIXME: handle more type of preposes
    case prep.tag
    when .pre_ling?, .pre_gei3?
      prep.val = "làm" if prep.prev?(&.tag.content_words?)
    else
      prep.swap_val!
      pos |= MtlPos::AtTail if prep.at_tail?
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
