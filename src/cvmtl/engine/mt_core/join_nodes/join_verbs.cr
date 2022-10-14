require "./join_verbs/**"

module MT::Core
  def join_verb!(verb : MtNode, prev = verb.prev)
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
      PairNode.new(prev, verb, tag: PosTag::SubjVerb)
    end
  end

  private def join_verb_1!(verb : MtNode)
    verb = fuse_verb!(verb)
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
