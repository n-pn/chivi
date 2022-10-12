module MT::Core
  def join_verb!(verb : BaseNode, prev = verb.prev)
    verb = join_verb_1!(verb)

    case prev
    when .quantis?, .pro_dems?
      return verb if verb.succ.tag.pt_dep?
    when .pro_pers?
      # prev = join_pro_per!(prev)
    when .noun_words?
      prev = join_noun!(prev)
    else
      return verb
    end

    if prev.prep_form?
      verb.tap(&.add_prep(prev))
    else
      BasePair.new(prev, verb, tag: MapTag::SubjVerb)
    end
  end

  def join_verb_0!(verb : BaseNode, prev = verb.prev)
    return verb unless prev.vauxil?
    # FIXME: fix auxil values
    BasePair.new(prev, verb, tag: verb.tag, flip: false)
  end

  private def join_verb_1!(verb : BaseNode)
    verb = join_verb_0!(verb)
    advb = verb.prev

    has_advb = true

    case advb
    when .time_words?
      advb = join_time!(advb)
    when .advb_words?
      advb = join_advb!(advb)
    when .pt_dev?
      advb = join_udev!(advb)
    else
      has_advb = false
    end

    verb = VerbForm.new(verb) unless verb.is_a?(VerbForm)

    if has_advb
      advb.at_tail? ? verb.add_tail(advb) : verb.add_advb(advb)
    elsif advb.wd_zui?
      verb.add_tail(advb)
    end

    verb
  end
end
