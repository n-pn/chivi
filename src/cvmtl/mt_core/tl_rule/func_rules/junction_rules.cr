module CV::TlRule
  def can_combine_adjt?(left : MtNode, right : MtNode?)
    return right.adjts?
  end

  def fold_verb_junction!(junc : MtNode, verb = junc.prev, succ = junc.succ?)
    return unless verb && succ && is_concoord?(junc)

    case succ
    when .preposes?
      succ = fold_preposes!(succ)
    when .adverbs?
      succ = fold_adverbs!(succ)
    when .veno?
      succ = fold_veno!(succ)
    when .verbs?
      tag = verb.tag if succ.key == "过"
      succ = fold_verbs!(succ)
    end

    return unless tag || succ.verbs?
    fold!(verb, succ, tag: tag || succ.tag, dic: 4)
  end

  def fold_adjt_junction!(node : MtNode, prev = node.prev?, succ = node.succ?)
    return unless prev && succ && is_concoord?(node)
    return unless (succ = scan_adjt!(succ)) && succ.adjts?

    fold!(prev, succ, tag: PosTag::Aform, dic: 4)
  end

  def fold_noun_concoord!(node : MtNode, prev = node.prev?, succ = node.succ?)
    # puts [node, prev, succ]
    return unless prev && succ
    return if node.key == "而" || !is_concoord?(node, check_prepos: true)

    if prev.tag == succ.tag
      fold!(prev, succ, tag: prev.tag, dic: 4)
    elsif (succ = scan_noun!(succ)) && similar_tag?(prev, succ)
      fold!(prev, succ, tag: PosTag::Nform, dic: 4)
    end
  end

  def is_concoord?(node : Nil)
    false
  end

  def is_concoord?(node : MtNode, check_prepos = false)
    case node
    when .penum?
      true
    when .concoord?
      return true unless node.key == "和"
      if check_prepos && he2_is_prepos?(node)
        false
      else
        node.val = "và"
        true
      end
    else
      node.key.in?({"但", "又", "或", "或是"})
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
    return false if verb.uniques?

    # TODO: add more white list?
    # puts [verb, node]
    node = fold!(node, succ, PosTag::PrepPhrase, dic: 5)
    fold!(node, scan_verb!(verb), verb.tag, dic: 6)

    # TOD: fold as subject + verb structure?
    return true
  end
end
