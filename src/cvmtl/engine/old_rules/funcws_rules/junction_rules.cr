module MT::TlRule
  def can_combine_adjt?(left : MtNode, right : MtNode?)
    # TODO
    right.adjt_words?
  end

  # ameba:disable Metrics/CyclomaticComplexity
  def fold_verb_junction!(junc : MtNode, verb = junc.prev, succ = junc.succ?)
    return unless verb && succ && succ.maybe_verb? && is_concoord?(junc)

    succ = heal_mixed!(succ) if succ.polysemy?

    case succ
    when .preposes?
      succ = fold_preposes!(succ)
    when .advb_words?
      succ = fold_adverbs!(succ)
    when .verbal_words?
      tag = verb.tag if succ.key == "过"
      succ = fold_verbs!(succ)
    end

    return unless tag || succ.verbal_words?
    fold!(verb, succ, tag: tag || succ.tag)
  end

  def fold_adjt_junction!(node : MtNode, prev = node.prev?, succ = node.succ?)
    return unless prev && succ && is_concoord?(node)
    return unless (succ = scan_adjt!(succ)) && succ.adjt_words?

    fold!(prev, succ, tag: PosTag.make(:amix))
  end

  def fold_noun_concoord!(node : MtNode, prev = node.prev?, succ = node.succ?)
    return unless prev && succ
    return if node.key == "而" || !is_concoord?(node)

    if prev.tag == succ.tag
      fold!(prev, succ, tag: prev.tag)
    elsif (succ = scan_noun!(succ)) && similar_tag?(prev, succ)
      fold!(prev, succ, tag: PosTag::Nform)
    end
  end

  def should_fold_noun_concoord?(noun : MtNode, concoord : MtNode) : Bool
    return true unless (prev = noun.prev?) && (succ = concoord.succ?)
    return false if prev.numeral? || prev.all_prons?
    return true unless prev.ptcl_dep? && (prev = prev.prev?)

    case prev.tag
    when .nform?     then true
    when .cap_human? then !succ.cap_human?
    else                  false
    end
  end

  def is_concoord?(node : Nil)
    false
  end

  def is_concoord?(node : MtNode)
    case node
    when .cenum?, .concoord? then true
    else
      {"但", "又", "或", "或是"}.includes?(node.key)
    end
  end

  def similar_tag?(left : MtNode, right : MtNode)
    case left.tag
    when .nform?        then true
    when .cap_human?    then right.cap_human?
    when .common_nouns? then right.common_nouns? || right.pro_dem?
    else
      right.nform? || right.tag == left.tag
    end
  end

  def he2_is_prepos?(node : MtNode, succ = node.succ?) : Bool
    return false unless succ && (verb = find_verb_after_for_prepos(succ))
    return false if verb.uniqword?

    # TODO: add more white list?
    # puts [verb, node]
    node = fold!(node, succ, PosTag::PrepForm)
    fold!(node, scan_verb!(verb), verb.tag)

    # TOD: fold as subject + verb structure?
    true
  end
end
