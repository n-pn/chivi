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

    # return node unless succ && succ.nouns?
    # succ = fold_noun!(succ)
    # if (succ_2 = succ.succ?) && succ_2.space?
    #   succ = fold_noun_space!(succ, succ_2)
    # end

    # # puts [node, succ, succ.succ?]
    # return node unless succ.succ?(&.ude1?)

    # node.val = "ở"

    # if (prev = node.prev?) && prev.verbs?
    #   node = prev
    # end

    # fold!(node, succ, PosTag::DefnPhrase, dic: 9)
  end

  def fold_prepos!(node : MtNode, noun = node.succ?) : MtNode
    return node unless noun && !noun.ends?

    noun = scan_noun!(noun, mode: 1)
    return node unless noun.center_noun? && (verb = noun.succ?)

    # combine with ude1
    if verb.ude1? && (tail = verb.succ?)
      tail = scan_noun!(tail)

      unless tail.succ?(&.maybe_verb?)
        node = fold!(node, verb.set!(""), PosTag::PrepPhrase, dic: 5)
        return fold!(node, tail, PosTag::NounPhrase, dic: 6, swap: true)
      end

      noun = fold_ude1_left!(tail, verb, noun)
      verb = tail.succ?
    end

    # fix prepos meaning
    swap = false

    case node.key
    when "给"
      node.val = "cho"
      swap = true
    when "让"
      node.val = "khiến cho"
    end

    node = fold!(node, noun, PosTag::PrepPhrase, dic: 5)

    case verb
    when .nil?     then return node
    when .adverbs? then verb = fold_adverbs!(verb)
    when .verb?    then verb = fold_verbs!(verb)
    end

    verb = fold!(node, verb, verb.tag, dic: 8, swap: swap)
    return verb if verb.verb_object? || verb.vintr?
    return verb unless (tail = verb.succ?) && !tail.ends?

    tail = scan_noun!(tail)
    fold!(verb, tail, PosTag::VerbObject, dic: 8)
  end
end
