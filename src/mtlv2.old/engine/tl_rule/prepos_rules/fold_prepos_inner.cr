module MtlV2::TlRule
  # ameba:disable Metrics/CyclomaticComplexity
  def fold_prepos_inner!(prepos : BaseNode, succ = prepos.succ?) : BaseNode
    return prepos unless (noun = scan_noun!(succ)) && noun.subject?
    return fold!(prepos, noun, PosTag::PrepClause, dic: 2) unless verb = noun.succ?

    # combine with noun after ude1 if there exists verb right after
    if verb.pd_dep? && (tail = scan_noun!(verb.succ?))
      # TODO: combine this part with `fold_prepos_left`

      unless verb_2 = find_verb_after_for_prepos(tail, skip_comma: false)
        if tail.succ? { |x| x.ends? || x.subject? }
          noun = fold_ude1!(ude1: verb, left: noun, right: tail)
          return fold!(prepos, noun, PosTag::VerbObject, dic: 9)
        end

        if prepos.pre_zai? && (noun = fold_prezai_places?(prepos, noun, verb, tail))
          return fold!(prepos, noun, PosTag::PrepClause, dic: 3)
        end

        prepos = fold!(prepos, verb.set!(""), PosTag::PrepClause, dic: 5)
        return fold!(prepos, tail, PosTag::NounPhrase, dic: 6, flip: true)
      end

      # puts [verb_2, verb, tail]

      fold_prepos_left(prepos, noun, ude1: verb, tail: tail).try { |x| return x }

      noun = fold_ude1!(ude1: verb, left: noun, right: tail)
      noun = fold_noun_after!(noun) unless verb_2.locative?

      verb = noun.succ?
    end

    head = fold!(prepos, noun, PosTag::PrepClause, dic: 4)

    case verb
    when .nil?, .v_shi?, .v_you?
      return head
    when .adverbial? then verb = fold_adverbs!(verb)
    when .pl_veno?   then verb = fold_verbs!(MtDict.fix_verb!(verb))
    when .verbal?    then verb = fold_verbs!(verb)
    else                  return head
    end

    return head unless verb.verbal?

    flip = false

    # fix prepos meaning
    case prepos.key
    when "自" then prepos.val = "từ"
    when "让" then prepos.val = "khiến"
    when "令" then prepos.val = "làm" if head.prev?(&.subject?)
    when "给" then prepos.val = "cho" if head.prev?(&.subject?)
    when "对"
      prepos.val = "với"
      flip = true
    end

    node = fold!(head, verb, verb.tag, dic: 8, flip: flip)
    return node unless (ude1 = node.succ?) && ude1.pd_dep?

    # if !node.v0_obj? && (prev = node.prev?) && prev.subject?
    #   node = fold!(prev, node, PosTag::VerbClause, dic: 7) unless mode == 3
    # end

    fold_ude1!(ude1: ude1, left: node)
  end

  def fold_prepos_left(prepos : BaseNode, noun : BaseNode, ude1 : BaseNode, tail : BaseNode)
    # puts [prepos, noun, ude1, tail, prepos.prev?]

    case prepos.prev?
    when .nil?, .pro_dems?, .pro_ints?
      left = fold!(prepos, ude1.set!(""), PosTag::DefnPhrase, dic: 6)
      fold!(left, tail, PosTag::NounPhrase, dic: 9, flip: true)
    else
      # TODO
    end
  end
end
