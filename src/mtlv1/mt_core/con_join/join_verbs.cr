module CV::TlRule
  def join_verb!(verb : BaseNode, prev = verb.prev)
    if prev.vauxil?
      verb = BasePair.new(prev, verb, tag: verb.tag, dic: 3, flip: false)
      prev = verb.prev
    end

    verb, prev = join_verb_advb!(verb, prev)

    case prev
    when .quantis?, .pro_dems?
      return verb if verb.succ.tag.pt_dep?
    when .pro_pers?
      prev = join_pro_per!(prev)
    when .noun_words?
      prev = join_noun!(prev)
    else
      return verb
    end

    if prev.prep_form?
      verb.tap(&.add_prep(prev))
    else
      BasePair.new(prev, verb, tag: PosTag::SubjVerb, dic: 4)
    end
  end

  private def join_verb_advb!(verb : BaseNode, advb : BaseNode)
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
      verb.add_advb(advb)
      prev = verb.prev
    elsif prev.wd_zui?
      verb.add_tail(prev)
      prev = verb.prev
    else
      prev = advb
    end

    {verb, prev}
  end
end
