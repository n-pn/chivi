module CV::TlRule
  def fold_pro_per!(node : MtNode, succ : Nil) : MtNode
    node
  end

  # ameba:disable Metrics/CyclomaticComplexity
  def fold_pro_per!(proper : MtNode, succ : MtNode) : MtNode
    case succ.tag
    when .concoord?, .penum?
      fold_noun_concoord!(succ, proper) || proper
    when .veno?
      succ = heal_veno!(succ)
      succ.noun? ? fold_proper_nounish!(proper, succ) : fold_noun_verb!(proper, succ)
    when .verbs?, .vmodals?
      fold_noun_verb!(proper, succ)
    when .ajno?
      succ = heal_ajno!(succ)
      succ.noun? ? fold_proper_nounish!(proper, succ) : proper
    when .pro_per?
      if tail = succ.succ?
        succ = fold_pro_per!(succ, tail)
      end

      noun = fold_proper_nounish!(proper, succ)
      return noun unless (succ = noun.succ?) && succ.maybe_verb?
      fold_noun_verb!(noun, succ)
    when .nouns?, .numbers?, .pro_dems?
      return proper if !(succ = scan_noun!(succ)) || succ.pro_dems?
      noun = fold_proper_nounish!(proper, succ)
      return noun unless (succ = noun.succ?) && succ.maybe_verb?
      fold_noun_verb!(noun, succ)
    when .uzhi?
      fold_uzhi!(uzhi: succ, prev: proper)
    when .ude1?
      return proper if proper.prev? { |x| x.verbs? || x.preposes? }
      fold_ude1!(ude1: succ, prev: proper)
    else
      # TODO: handle special cases
      proper
    end
  end

  # ameba:disable Metrics/CyclomaticComplexity
  def fold_proper_nounish!(proper : MtNode, nounish : MtNode) : MtNode
    return proper unless noun_can_combine?(proper.prev?, nounish.succ?)
    if (prev = proper.prev?) && need_2_objects?(prev)
      flip = false

      if (succ = nounish.succ?) && (succ.ude1?)
        nounish = fold_ude1!(ude1: succ, prev: nounish)
      end
    else
      flip = !nounish.pro_per? || nounish.key == "自己"
    end

    case nounish.tag
    when .space?
      fold_noun_space!(proper, nounish)
    when .person?
      fold!(proper, nounish, proper.tag, dic: 4, flip: false)
    when .nqtime?
      flip = !nounish.succ?(&.ends?) if flip
      fold!(proper, nounish, nounish.tag, dic: 4, flip: flip)
    when .place?
      fold!(proper, nounish, nounish.tag, dic: 4, flip: flip)
    when .names?, .ptitle?, .noun?
      # TODO: add pseudo proper
      proper.val = "của #{proper.val}" if flip
      fold!(proper, nounish, nounish.tag, dic: 4, flip: flip)
    else
      fold!(proper, nounish, PosTag::Nform, dic: 8, flip: false)
    end
  end

  def flip_proper_noun?(proper : MtNode, noun : MtNode) : Bool
    return !noun.nqtime? unless (prev = proper.prev?) && prev.verbs?
    !need_2_objects?(prev)
  end
end
