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
      # TODO: check conditions when prezai can be translated at "đang"
      # node.set!("đang")

      node = fold!(node, succ, succ.tag, dic: 6)
      return fold_verbs!(node)
    end

    fold_prepos!(node, succ, mode: mode)
  end

  def fold_prezai_places?(node : MtNode, noun : MtNode, ude1 : MtNode, tail : MtNode) : MtNode?
    return nil if noun.places?

    unless tail.places?
      return nil unless tail = fold_noun_space!(noun: tail)
    end

    fold_noun_ude1!(noun, ude1, tail)
  end

  def fold_prepos!(prepos : MtNode, succ = prepos.succ?, mode = 0) : MtNode
    return prepos unless (noun = scan_noun!(succ, mode: 0)) && noun.subject?
    return fold!(prepos, noun, PosTag::PrepPhrase, dic: 2) unless verb = noun.succ?

    # combine with noun after ude1 if there exists verb right after
    if verb.ude1? && (tail = scan_noun!(verb.succ?, mode: mode))
      # TODO: combine this part with `fold_prepos_left`

      unless find_verb_after_for_prepos(tail, skip_comma: false)
        if prepos.pre_zai? && (noun = fold_prezai_places?(prepos, noun, verb, tail))
          return fold!(prepos, noun, PosTag::PrepPhrase, dic: 3)
        end

        prepos = fold!(prepos, verb.set!(""), PosTag::PrepPhrase, dic: 5)
        return fold!(prepos, tail, PosTag::NounPhrase, dic: 6, flip: true)
      end

      fold_prepos_left(prepos.prev?, noun, ude1: verb, tail: tail).try { |x| return x }

      noun = fold_noun_ude1!(noun, ude1: verb, right: tail)
      verb = noun.succ?
    end

    # fix prepos meaning
    flip = false

    case prepos.key
    when "给"
      if prepos.prev?(&.subject?)
        prepos.val = "cho"
        flip = true
      end
    when "令"
      prepos.val = "làm" if prepos.prev?(&.subject?)
    when "自"
      prepos.val = "từ"
    when "让"
      # prepos.val = "nhường"
    end

    prepos = fold!(prepos, noun, PosTag::PrepPhrase, dic: 5)

    case verb
    when .nil?     then return prepos
    when .adverbs? then verb = fold_adverbs!(verb)
    when .veno?    then verb = fold_verbs!(verb.set!(PosTag::Verb))
    when .verb?    then verb = fold_verbs!(verb)
    end

    return prepos unless verb.verbs?
    node = fold!(prepos, verb, verb.tag, dic: 8, flip: flip)
    node.succ? { |x| fold_ude1!(x, prev: node) if mode == 1 && x.ude1? } || node
  end

  def fold_prepos_left(prev : MtNode?, noun : MtNode, ude1 : MtNode, tail : MtNode)
    return unless prev && prev.subject?
    return unless verb = find_verb_after_for_prepos(tail, skip_comma: false)

    return unless verb.v_shi? || verb.key == "就是"
    return if find_verb_after(verb)

    ude1.val = ""
    node = fold!(prev, noun, PosTag::NounPhrase, dic: 8)
    return fold!(node, tail, PosTag::NounPhrase, dic: 9, flip: true)
  end
end
