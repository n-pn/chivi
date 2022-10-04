module MtlV2::TlRule
  def fold_proper!(node : BaseNode, succ : Nil) : BaseNode
    node
  end

  # ameba:disable Metrics/CyclomaticComplexity
  def fold_proper!(proper : BaseNode, succ : BaseNode) : BaseNode
    # puts [proper, succ]

    case succ.tag
    when .junction?
      fold_noun_junction!(succ, proper) || proper
    when .pl_veno?
      succ = heal_veno!(succ)
      succ.noun? ? fold_proper_nominal!(proper, succ) : fold_noun_verb!(proper, succ)
    when .verbal?, .vmodals?
      fold_noun_verb!(proper, succ)
    when .pl_ajno?
      succ = heal_ajno!(succ)
      succ.noun? ? fold_proper_nominal!(proper, succ) : proper
    when .pro_per?
      if tail = succ.succ?
        succ = fold_proper!(succ, tail)
      end

      noun = fold_proper_nominal!(proper, succ)
      return noun unless (succ = noun.succ?) && succ.maybe_verb?
      fold_noun_verb!(noun, succ)
    when .nominal?
      succ = fold_nouns!(succ)
      return proper unless succ.nominal?
      fold_proper_nominal!(proper, succ)
    when .numeral?
      succ = fold_number!(succ)
      return proper if succ.temporal? || succ.nqtime?
      fold_proper_nominal!(proper, succ)
    when .pro_dems?
      return proper if !(succ = scan_noun!(succ.succ?, prodem: succ)) || succ.pro_dems?
      noun = fold_proper_nominal!(proper, succ)
      return noun unless (succ = noun.succ?) && succ.maybe_verb?
      fold_noun_verb!(noun, succ)
    when .uzhi?
      fold_uzhi!(uzhi: succ, prev: proper)
    when .ude1?
      fold_mode = NounMode.init(proper, proper.prev?)
      return proper unless right = fold_right_of_ude1(proper, fold_mode, succ.succ?)
      fold_ude1!(ude1: succ, left: proper, right: right)
    else
      # TODO: handle special cases
      proper
    end
  end

  # ameba:disable Metrics/CyclomaticComplexity
  def fold_proper_nominal!(proper : BaseNode, nominal : BaseNode) : BaseNode
    # puts [proper, nominal]

    if nominal.position?
      noun = fold!(proper, nominal, nominal.tag, dic: 2, flip: true)
      return fold_noun_other!(noun)
    end

    if (prev = proper.prev?) && prev.flag.need2_obj?
      flip = false

      if (succ = nominal.succ?) && (succ.ude1?)
        nominal = fold_ude1!(ude1: succ, left: nominal)
      end
    else
      flip = !nominal.pro_per? || nominal.key == "自己"
    end

    case nominal.tag
    when .locative?
      fold_noun_locality!(proper, nominal)
    when .person?
      fold!(proper, nominal, proper.tag, dic: 4, flip: false)
    when .nqtime?
      flip = !nominal.succ?(&.ends?) if flip
      fold!(proper, nominal, nominal.tag, dic: 4, flip: flip)
    when .position?
      fold!(proper, nominal, nominal.tag, dic: 4, flip: flip)
    when .names?, .ptitle?, .noun?
      # TODO: add pseudo proper
      proper.val = "của #{proper.val}" if flip
      fold!(proper, nominal, nominal.tag, dic: 4, flip: flip)
    else
      fold!(proper, nominal, PosTag::NounPhrase, dic: 8, flip: false)
    end
  end

  def flip_proper_noun?(proper : BaseNode, noun : BaseNode) : Bool
    return !noun.nqtime? unless (prev = proper.prev?) && prev.verbal?
    !need_2_objects?(prev)
  end
end
