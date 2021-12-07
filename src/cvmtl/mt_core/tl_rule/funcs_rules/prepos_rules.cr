module CV::TlRule
  def fold_preposes!(node : MtNode, succ = node.succ?) : MtNode
    return node unless succ

    # TODO!
    case node.tag
    when .pre_dui? then fold_pre_dui!(node, succ)
    when .pre_bei? then fold_pre_bei!(node, succ)
    when .pre_zai? then fold_pre_zai!(node, succ)
    else                fold_prepos!(node, succ)
    end
  end

  def fold_pre_dui!(node : MtNode, succ = node.succ?) : MtNode
    return node.set!("đúng", PosTag::Unkn) unless succ && !succ.ends?

    # TODO: combine grammar

    case succ.tag
    when .ude1?
      fold!(node.set!("đúng"), succ.set!(""), PosTag::Unkn, dic: 7)
    when .ule?
      succ.val = "" unless keep_ule?(node, succ)
      fold!(node.set!("đúng"), succ, PosTag::Unkn, dic: 7)
    when .ends?, .conjunct?, .concoord?
      node.set!("đúng", PosTag::Adjt)
    when .contws?, .popens?
      fold_prepos!(node.set!("đối với"), succ)
    else
      node
    end
  end

  def fold_pre_bei!(node : MtNode, succ = node.succ?) : MtNode
    return node unless succ

    if succ.verb?
      # todo: change "bị" to "được" if suitable
      node = fold!(node, succ, succ.tag, dic: 5)
      fold_verbs!(node)
    else
      fold_prepos!(node, succ)
    end
  end

  def fold_pre_zai!(node : MtNode, succ = node.succ?) : MtNode
    fold_prepos!(node, succ)

    if succ.verb?
      node = fold!(node, succ, succ.tag, dic: 5)
      fold_verbs!(node)
    else
      fold_prepos!(node, succ)
    end
  end

  def fold_prepos!(node : MtNode, noun = node.succ?) : MtNode
    return node unless noun = scan_noun!(noun, mode: 0)
    return node unless verb = noun.succ?

    # combine with noun after ude1 if there exists verb right after
    if verb.ude1? && (tail = scan_noun!(verb.succ?, mode: 0))
      unless found = find_verb_after_for_prepos(tail, skip_comma: false)
        node = fold!(node, verb.set!(""), PosTag::PrepPhrase, dic: 5)
        return fold!(node, tail, PosTag::NounPhrase, dic: 6, flip: true)
      end

      noun = fold_noun_ude1_noun!(noun, ude1: verb, right: tail)
      verb = noun.succ?
    end

    # fix prepos meaning
    flip = false

    case node.key
    when "给"
      node.val = "cho"
      flip = true
    when "让"
      # node.val = "nhường"
    end

    node = fold!(node, noun, PosTag::PrepPhrase, dic: 5)

    case verb
    when .nil?     then return node
    when .adverbs? then verb = fold_adverbs!(verb)
    when .verb?    then verb = fold_verbs!(verb)
    end

    return node unless verb.verbs?

    verb = fold!(node, verb, verb.tag, dic: 8, flip: flip)
    return verb if verb.verb_object? || verb.vintr?
    return verb unless tail = scan_noun!(verb.succ?, mode: 1)
    fold!(verb, tail, PosTag::VerbObject, dic: 6)
  end
end
