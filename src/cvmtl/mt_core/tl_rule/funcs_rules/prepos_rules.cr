module CV::TlRule
  def fold_preposes!(node : MtNode, succ = node.succ?, mode = 0) : MtNode
    return node unless succ

    # TODO!
    case node.tag
    when .pre_dui? then fold_pre_dui!(node, succ, mode: mode)
    when .pre_bei? then fold_pre_bei!(node, succ, mode: mode)
    when .pre_zai? then fold_pre_zai!(node, succ, mode: mode)
    else                fold_prepos!(node, succ, mode: mode)
    end
  end

  def fold_pre_dui!(node : MtNode, succ = node.succ?, mode = 0) : MtNode
    return node.set!("đúng", PosTag::Unkn) unless succ && !succ.ends?

    # TODO: combine grammar

    case succ.tag
    when .ude1?
      fold!(node.set!("đúng"), succ.set!(""), PosTag::Unkn, dic: 7)
    when .ule?
      # succ.val = "" unless keep_ule?(node, succ)
      fold!(node.set!("đúng"), succ, PosTag::Unkn, dic: 7)
    when .ends?, .conjunct?, .concoord?
      node.set!("đúng", PosTag::Adjt)
    when .contws?, .popens?
      fold_prepos!(node.set!("đối với"), succ, mode: mode)
    else
      node
    end
  end

  def fold_pre_bei!(node : MtNode, succ = node.succ?, mode = 0) : MtNode
    return node unless succ

    if succ.verb?
      # todo: change "bị" to "được" if suitable
      node = fold!(node, succ, succ.tag, dic: 5)
      fold_verbs!(node)
    else
      fold_prepos!(node, succ, mode: mode)
    end
  end

  def fold_pre_zai!(node : MtNode, succ = node.succ?, mode = 0) : MtNode
    if succ.verb? || succ.verb_object?
      node = fold!(node.set!("đang"), succ, succ.tag, dic: 6)
      return fold_verbs!(node)
    end

    fold_prepos!(node, succ, mode: mode)
  end

  def fold_prezai_places?(node : MtNode, noun : MtNode, ude1 : MtNode, tail : MtNode) : MtNode?
    return nil if noun.places?

    unless tail.places?
      return nil unless tail = fold_noun_space!(noun: tail)
    end

    fold_noun_ude1_noun!(noun, ude1, tail)
  end

  def fold_prepos!(node : MtNode, noun = node.succ?, mode = 0) : MtNode
    return node unless noun = scan_noun!(noun, mode: 0)
    return fold!(node, noun, PosTag::PrepPhrase, dic: 2) unless verb = noun.succ?

    # combine with noun after ude1 if there exists verb right after
    if verb.ude1? && (tail = scan_noun!(verb.succ?, mode: mode))
      unless find_verb_after_for_prepos(tail, skip_comma: false)
        if node.pre_zai? && (noun = fold_prezai_places?(node, noun, verb, tail))
          return fold!(node, noun, PosTag::PrepPhrase, dic: 3)
        end

        node = fold!(node, verb.set!(""), PosTag::PrepPhrase, dic: 5)
        return fold!(node, tail, PosTag::NounPhrase, dic: 6, flip: true)
      end

      if tail.succ?(&.v_shi?) && (prev = node.prev?) && prev.center_noun?
        verb.val = "của"
        node = fold!(prev, noun, PosTag::NounPhrase, dic: 8)
        return fold!(node, tail, PosTag::NounPhrase, dic: 9, flip: true)
      else
        noun = fold_noun_ude1_noun!(noun, ude1: verb, right: tail)
        verb = noun.succ?
      end
    end

    # fix prepos meaning
    flip = false

    case node.key
    when "给"
      node.val = "cho"
      flip = true
    when "令"
      node.val = "làm"
    when "让"
      # node.val = "nhường"
    end

    node = fold!(node, noun, PosTag::PrepPhrase, dic: 5)

    case verb
    when .nil?     then return node
    when .adverbs? then verb = fold_adverbs!(verb)
    when .veno?    then verb = fold_verbs!(verb.set!(PosTag::Verb))
    when .verb?    then verb = fold_verbs!(verb)
    end

    return node unless verb.verbs?

    verb = fold!(node, verb, verb.tag, dic: 8, flip: flip)
    unless verb.verb_object? || verb.vintr?
      return verb unless tail = scan_noun!(verb.succ?, mode: 0)
      verb = fold!(verb, tail, PosTag::VerbObject, dic: 5)
    end

    return verb unless mode == 1 && (ude1 = verb.succ?) && ude1.ude1?
    fold_ude1!(ude1, verb)
  end
end
