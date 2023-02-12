module M1::TlRule
  def fold_pro_per!(node : MtNode, succ : Nil) : MtNode
    node
  end

  # ameba:disable Metrics/CyclomaticComplexity
  def fold_pro_per!(proper : MtNode, succ : MtNode) : MtNode
    succ = heal_mixed!(succ) if succ.polysemy?

    case succ.tag
    when .concoord?, .penum?
      fold_noun_concoord!(succ, proper) || proper
    when .verbal?, .vmodals?
      fold_noun_verb!(proper, succ)
    when .pro_per?
      if tail = succ.succ?
        succ = fold_pro_per!(succ, tail)
      end

      noun = fold_proper_nominal!(proper, succ)
      return noun unless (succ = noun.succ?) && succ.maybe_verb?
      fold_noun_verb!(noun, succ)
    when .nominal?, .numbers?, .pro_dems?
      return proper if !(succ = scan_noun!(succ)) || succ.pro_dems?
      noun = fold_proper_nominal!(proper, succ)
      return noun unless (succ = noun.succ?) && succ.maybe_verb?
      fold_noun_verb!(noun, succ)
    when .uzhi?
      fold_uzhi!(uzhi: succ, prev: proper)
    when .ude1?
      return proper if proper.prev? { |x| x.verbal? || x.preposes? }
      fold_ude1!(ude1: succ, prev: proper)
    else
      # TODO: handle special cases
      proper
    end
  end

  # ameba:disable Metrics/CyclomaticComplexity
  def fold_proper_nominal!(proper : MtNode, nominal : MtNode) : MtNode
    return proper unless noun_can_combine?(proper.prev?, nominal.succ?)
    if (prev = proper.prev?) && prev.v2_obj?
      flip = false

      if (succ = nominal.succ?) && (succ.ude1?)
        nominal = fold_ude1!(ude1: succ, prev: nominal)
      end
    else
      flip = !nominal.pro_per? || nominal.key == "自己"
    end

    case nominal.tag
    when .locat?
      fold_noun_space!(proper, nominal)
    when .person?
      fold!(proper, nominal, proper.tag, dic: 4, flip: false)
    when .nqtime?
      flip = !nominal.succ?(&.ends?) if flip
      fold!(proper, nominal, nominal.tag, dic: 4, flip: flip)
    when .posit?
      fold!(proper, nominal, nominal.tag, dic: 4, flip: flip)
    when .names?, .honor?, .noun?
      # TODO: add pseudo proper
      proper.val = "của #{proper.val}" if flip
      fold!(proper, nominal, nominal.tag, dic: 4, flip: flip)
    else
      fold!(proper, nominal, PosTag::Nform, dic: 8, flip: false)
    end
  end

  def flip_proper_noun?(proper : MtNode, noun : MtNode) : Bool
    return !noun.nqtime? unless (prev = proper.prev?) && prev.verbal?
    !need_2_objects?(prev)
  end
end
