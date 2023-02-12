module M1::TlRule
  def can_combine_adjt?(left : MtNode, right : MtNode?)
    # TODO
    right.adjective?
  end

  # ameba:disable Metrics/CyclomaticComplexity
  def fold_verb_junction!(junc : MtNode, verb = junc.prev, succ = junc.succ?)
    return unless verb && succ && succ.maybe_verb? && is_concoord?(junc)

    succ = heal_mixed!(succ) if succ.polysemy?

    case succ
    when .preposes?
      succ = fold_preposes!(succ)
    when .adverbial?
      succ = fold_adverbs!(succ)
    when .verbal?
      tag = verb.tag if succ.key == "过"
      succ = fold_verbs!(succ)
    end

    return unless tag || succ.verbal?
    fold!(verb, succ, tag: tag || succ.tag, dic: 4)
  end

  def fold_adjt_junction!(node : MtNode, prev = node.prev?, succ = node.succ?)
    return unless prev && succ && is_concoord?(node)
    return unless (succ = scan_adjt!(succ)) && succ.adjective?

    fold!(prev, succ, tag: PosTag::Aform, dic: 4)
  end

  def fold_noun_concoord!(node : MtNode, prev = node.prev?, succ = node.succ?)
    return unless prev && succ
    return if node.key == "而" || !is_concoord?(node)

    if prev.tag == succ.tag
      fold!(prev, succ, tag: prev.tag, dic: 4)
    elsif (succ = scan_noun!(succ)) && similar_tag?(prev, succ)
      fold!(prev, succ, tag: PosTag::Nform, dic: 4)
    end
  end

  def should_fold_noun_concoord?(noun : MtNode, concoord : MtNode) : Bool
    return true unless (prev = noun.prev?) && (succ = concoord.succ?)
    return false if prev.numeral? || prev.pronouns?
    return true unless prev.ude1? && (prev = prev.prev?)

    case prev.tag
    when .nform? then true
    when .human? then !succ.human?
    else              false
    end
  end

  def is_concoord?(node : Nil)
    false
  end

  def is_concoord?(node : MtNode)
    case node
    when .penum?, .concoord? then true
    else
      {"但", "又", "或", "或是"}.includes?(node.key)
    end
  end

  def similar_tag?(left : MtNode, right : MtNode)
    case left.tag
    when .nform? then true
    when .human? then right.human?
    when .noun?  then right.noun? || right.pro_dem?
    else
      right.nform? || right.tag == left.tag
    end
  end

  def he2_is_prepos?(node : MtNode, succ = node.succ?) : Bool
    return false unless succ && (verb = find_verb_after_for_prepos(succ))
    return false if verb.specials?

    # TODO: add more white list?
    # puts [verb, node]
    node = fold!(node, succ, PosTag::PrepClause, dic: 6)
    fold!(node, scan_verb!(verb), verb.tag, dic: 6)

    # TOD: fold as subject + verb structure?
    true
  end
end
