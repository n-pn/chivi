module CV::TlRule
  def fold_pro_per!(node : MtNode, succ : Nil) : MtNode
    node
  end

  def fold_pro_per!(node : MtNode, succ : MtNode) : MtNode
    case succ.tag
    when .concoord?, .penum?
      fold_noun_concoord!(succ, node) || node
    when .veno?
      succ = heal_veno!(succ)
      succ.noun? ? fold_proper_nounish!(node, succ) : fold_noun_verb!(node, succ)
    when .verbs?, .vmodals?
      return fold_noun_verb!(node, succ)
    when .ajno?
      succ = heal_ajno!(succ)
      succ.noun? ? fold_proper_nounish!(node, succ) : node
    when .pro_per?
      # TODO: check for linking verb
      return node if node.prev?(&.verbs?) && succ.succ?(&.verbs?)

      flip = succ.key == "自己"
      node = fold!(node, succ, node.tag, dic: 7, flip: flip)
    when .nouns?, .numbers?, .pro_dems?
      return node unless (succ = scan_noun!(succ)) && succ.object? && !succ.pro_dems?
      fold_proper_nounish!(node, succ)
    when .uzhi?
      fold_uzhi!(uzhi: succ, prev: node)
    else
      # TODO: handle special cases
      node
    end
  end

  def fold_proper_nounish!(proper : MtNode, nounish : MtNode) : MtNode
    return proper unless noun_can_combine?(proper.prev?, nounish.succ?)
    if (prev = proper.prev?) && need_2_objects?(prev)
      flip = false

      if (succ = nounish.succ?) && (succ.ude1?)
        nounish = fold_ude1!(ude1: succ, prev: nounish)
      end
    else
      flip = true
    end

    case nounish.tag
    when .space?
      fold_noun_space!(proper, nounish)
    when .place?
      fold!(proper, nounish, PosTag::DefnPhrase, dic: 4, flip: flip)
    when .person?
      fold!(proper, nounish, proper.tag, dic: 4, flip: false)
    when .nqtime?
      flip = !nounish.succ?(&.ends?) if flip
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

    prev.each do |node|
      return false if need_2_objects?(node.key)
    end

    true
  end
end
