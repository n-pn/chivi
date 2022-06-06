module CV::TlRule
  def fold_verb_junction!(junc : MtNode, verb = junc.prev, succ = junc.succ?)
    return if !succ || succ.ends?
    return if tag = verb.tag if succ.key == "过"
    succ = fold_once!(succ)

    return unless tag || succ.verbal?
    fold!(verb, succ, tag: tag || succ.tag, dic: 4)
  end

  def fold_noun_junction!(junc : MtNode, prev = junc.prev?, succ = junc.succ?)
    return if !succ || succ.ends? || junc.key == "而"

    if junc.preposes?
      return if fold_noun_junction_special!(prev, junc, succ)
      junc.val = "và" if junc.key == "和"
    end

    succ = fold_once!(succ)

    if (prev.tag == succ.tag)
      noun = fold!(prev, succ, tag: prev.tag, dic: 4)
    elsif similar_tag?(prev, succ) || (junc.penum? && succ.mixed?)
      noun = fold!(prev, succ, tag: PosTag::NounPhrase, dic: 4)
    else
      return nil
    end

    return noun unless (succ = noun.succ?) && (tail = succ.succ?) && succ.key.in?("与", "和")
    tail = fold_once!(tail)
    fold!(noun, tail, PosTag::NounPhrase, dic: 4)
  end

  def fold_noun_junction_special!(noun : MtNode, junc : MtNode, tail = junc.succ)
    if right = fold_compare_prepos(junc)
      right
    elsif has_verb_after?(tail)
      fold_prepos_inner!(junc, tail)
    end
  end

  # def should_fold_noun_junction?(noun : MtNode, concoord : MtNode) : Bool
  #   return true unless (prev = noun.prev?) && (succ = concoord.succ?)
  #   return false if prev.numeral? || prev.pronouns?
  #   return true unless prev.ude1? && (prev = prev.prev?)

  #   case prev.tag
  #   when .noun_phrase? then true
  #   when .human?       then !succ.human?
  #   else                    false
  #   end
  # end

  def similar_tag?(left : MtNode, right : MtNode)
    case left.tag
    when .noun_phrase? then true
    when .human?       then right.human?
    when .noun?        then right.noun? || right.pro_dem?
    else
      right.noun_phrase? || right.tag == left.tag
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
