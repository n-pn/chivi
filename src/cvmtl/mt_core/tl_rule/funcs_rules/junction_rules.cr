module CV::TlRule
  def can_combine_adjt?(left : MtNode, right : MtNode?)
    return right.adjts?
  end

  def fold_verb_junction!(junc : MtNode, verb = junc.prev, succ = junc.succ?)
    return unless verb && succ
    return unless succ.verb?

    if junc.concoord?
      junc.val = "và" if junc.key == "和"
    elsif junc.conjunct?
      return unless junc.key == "但" || junc.key == "又"
    end

    fold!(verb, succ, tag: succ.tag, dic: 4)
  end

  def fold_adjt_junction!(node : MtNode, prev = node.prev?, succ = node.succ?)
    return unless prev && succ

    if node.concoord?
      node.val = "và" if node.key == "和"
    elsif node.conjunct?
      return unless node.key == "但" || node.key == "又"
    end

    succ = scan_adjt!(succ)
    return unless succ.adjts?
    fold!(prev, succ, tag: PosTag::Aform, dic: 4)
  end

  def fold_noun_concoord!(node : MtNode, prev = node.prev?, succ = node.succ?)
    return unless prev && succ

    unless similar_tag?(prev, succ)
      return unless succ = scan_noun!(succ)
    end

    if node.key == "和"
      if (verb = find_verb_after_for_prepos(succ)) && !verb.uniques?
        # TODO: add more white list?
        # puts [verb, node]
        node = fold!(node, succ, PosTag::PrepPhrase, dic: 5)
        fold!(node, scan_verb!(verb), verb.tag, dic: 6)

        # TOD: fold as subject + verb structure?
        return
      else
        node.val = "và"
      end
    end

    fold!(prev, succ, tag: PosTag::Nform, dic: 4)
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
end
