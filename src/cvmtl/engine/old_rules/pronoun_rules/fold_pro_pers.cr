module MT::TlRule
  def fold_pro_per!(node : MtNode, succ : Nil) : MtNode
    node
  end

  # ameba:disable Metrics/CyclomaticComplexity
  def fold_pro_per!(proper : MtNode, succ : MtNode) : MtNode
    succ = heal_mixed!(succ) if succ.polysemy?

    case succ.tag
    when .concoord?, .cenum?
      fold_noun_concoord!(succ, proper) || proper
    when .common_verbs?, .vauxil?
      fold_noun_verb!(proper, succ)
    when .pro_pers?
      if tail = succ.succ?
        succ = fold_pro_per!(succ, tail)
      end

      noun = fold_proper_nominal!(proper, succ)
      return noun unless (succ = noun.succ?) && succ.maybe_verb?
      fold_noun_verb!(noun, succ)
    when .nominal?, .numbers?, .dem_prons?
      return proper if !(succ = scan_noun!(succ)) || succ.dem_prons?
      noun = fold_proper_nominal!(proper, succ)
      return noun unless (succ = noun.succ?) && succ.maybe_verb?
      fold_noun_verb!(noun, succ)
    when .ptcl_zhi?
      fold_uzhi!(uzhi: succ, prev: proper)
    when .ptcl_dep?
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

    if nominal.pro_ziji?
      nominal.val = "chính"
      flip = false
    elsif (prev = proper.prev?) && prev.vtwo?
      flip = false

      if (succ = nominal.succ?) && (succ.ptcl_dep?)
        nominal = fold_ude1!(ude1: succ, prev: nominal)
      end
    else
      flip = !nominal.pro_pers?
    end

    case nominal.tag
    when .locat?
      fold_noun_space!(proper, nominal)
    when .people?
      fold!(proper, nominal, proper.tag, flip: false)
    when .nqtime?
      flip = !nominal.succ?(&.boundary?) if flip
      fold!(proper, nominal, nominal.tag, flip: flip)
    when .posit?
      fold!(proper, nominal, nominal.tag, flip: flip)
    when .proper_nouns?, .common_noun?
      # TODO: add pseudo proper
      proper.val = "của #{proper.val}" if flip
      fold!(proper, nominal, nominal.tag, flip: flip)
    else
      fold!(proper, nominal, PosTag::Nform, flip: false)
    end
  end

  def flip_proper_noun?(proper : MtNode, noun : MtNode) : Bool
    return !noun.nqtime? unless (prev = proper.prev?) && prev.verbal?
    !need_2_objects?(prev)
  end
end