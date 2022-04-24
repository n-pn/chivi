module CV::TlRule
  # ameba:disable Metrics/CyclomaticComplexity
  def fold_prepos_inner!(prepos : MtNode, succ = prepos.succ?, mode = 0) : MtNode
    return prepos unless (noun = scan_noun!(succ, mode: 0)) && noun.subject?
    return fold!(prepos, noun, PosTag::PrepPhrase, dic: 2) unless verb = noun.succ?

    # combine with noun after ude1 if there exists verb right after
    if verb.ude1? && (tail = scan_noun!(verb.succ?))
      # TODO: combine this part with `fold_prepos_left`

      unless verb_2 = find_verb_after_for_prepos(tail, skip_comma: false)
        if prepos.pre_zai? && (noun = fold_prezai_places?(prepos, noun, verb, tail))
          return fold!(prepos, noun, PosTag::PrepPhrase, dic: 3)
        end

        prepos = fold!(prepos, verb.set!(""), PosTag::PrepPhrase, dic: 5)
        return fold!(prepos, tail, PosTag::NounPhrase, dic: 6, flip: true)
      end

      # puts [verb_2, verb, tail]

      fold_prepos_left(prepos, noun, ude1: verb, tail: tail).try { |x| return x }

      noun = fold_noun_ude1!(noun, ude1: verb, right: tail)
      noun = fold_noun_after!(noun) unless verb_2.spaces?

      verb = noun.succ?
    end

    head = fold!(prepos, noun, PosTag::PrepPhrase, dic: 4)

    case verb
    when .nil?, .v_shi?, .v_you?
      return head
    when .adverbs? then verb = fold_adverbs!(verb)
    when .veno?    then verb = fold_verbs!(MtDict.fix_verb!(verb))
    when .verbs?   then verb = fold_verbs!(verb)
    else                return head
    end

    return head unless verb.verbs?

    flip = false

    # fix prepos meaning
    case prepos.key
    when "令" then prepos.val = "làm" if head.prev?(&.subject?)
    when "自" then prepos.val = "từ"
    when "让"
      # prepos.val = "nhường"
    when "给"
      prepos.val = "cho" if head.prev?(&.subject?)
    when "对"
      prepos.val = "với"
      flip = true
    end

    node = fold!(head, verb, verb.tag, dic: 8, flip: flip)
    node.succ? { |x| fold_ude1!(x, prev: node) if mode == 1 && x.ude1? } || node
  end

  def fold_prepos_left(prepos : MtNode, noun : MtNode, ude1 : MtNode, tail : MtNode)
    # puts [prepos, noun, ude1, tail, prepos.prev?]
    return unless prepos.prev?(&.pro_dems?)
    left = fold!(prepos, ude1.set!(""), PosTag::DefnPhrase, dic: 6)
    fold!(left, tail, PosTag::NounPhrase, dic: 9, flip: true)
  end
end
