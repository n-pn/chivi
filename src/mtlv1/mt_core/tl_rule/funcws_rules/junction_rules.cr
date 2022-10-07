module CV::TlRule
  def can_combine_adjt?(left : BaseNode, right : BaseNode?)
    # TODO
    right.adjts?
  end

  # ameba:disable Metrics/CyclomaticComplexity
  def fold_verb_junction!(junc : BaseNode, verb = junc.prev, succ = junc.succ?)
    return unless verb && succ && succ.maybe_verb? && is_concoord?(junc)

    succ = heal_mixed!(succ) if succ.polysemy?

    case succ
    when .preposes?
      succ = fold_preposes!(succ)
    when .advbial?
      succ = fold_adverbs!(succ)
    when .verbal?
      tag = verb.tag if succ.key == "过"
      succ = fold_verbs!(succ)
    end

    return unless tag || succ.verbal?
    fold!(verb, succ, tag: tag || succ.tag, dic: 4)
  end

  def fold_adjt_junction!(node : BaseNode, prev = node.prev?, succ = node.succ?)
    return unless prev && succ && is_concoord?(node)
    return unless (succ = scan_adjt!(succ)) && succ.adjts?

    fold!(prev, succ, tag: PosTag::Aform, dic: 4)
  end

  def fold_noun_concoord!(node : BaseNode, prev = node.prev?, succ = node.succ?)
    return unless prev && succ
    return if node.key == "而" || !is_concoord?(node)

    if prev.tag == succ.tag
      fold!(prev, succ, tag: prev.tag, dic: 4)
    elsif (succ = scan_noun!(succ)) && similar_tag?(prev, succ)
      fold!(prev, succ, tag: PosTag::Nform, dic: 4)
    end
  end

  def should_fold_noun_concoord?(noun : BaseNode, concoord : BaseNode) : Bool
    return true unless (prev = noun.prev?) && (succ = concoord.succ?)
    return false if prev.numeral? || prev.pronouns?
    return true unless prev.pt_dep? && (prev = prev.prev?)

    case prev.tag
    when .nform?     then true
    when .cap_human? then !succ.cap_human?
    else                  false
    end
  end

  def is_concoord?(node : Nil)
    false
  end

  def is_concoord?(node : BaseNode)
    case node
    when .cenum?, .concoord? then true
    else
      {"但", "又", "或", "或是"}.includes?(node.key)
    end
  end

  def similar_tag?(left : BaseNode, right : BaseNode)
    case left.tag
    when .nform?     then true
    when .cap_human? then right.cap_human?
    when .nouns?     then right.nouns? || right.pro_dem?
    else
      right.nform? || right.tag == left.tag
    end
  end

  def he2_is_prepos?(node : BaseNode, succ = node.succ?) : Bool
    return false unless succ && (verb = find_verb_after_for_prepos(succ))
    return false if verb.uniqword?

    # TODO: add more white list?
    # puts [verb, node]
    node = fold!(node, succ, PosTag::PrepForm, dic: 6)
    fold!(node, scan_verb!(verb), verb.tag, dic: 6)

    # TOD: fold as subject + verb structure?
    true
  end
end
