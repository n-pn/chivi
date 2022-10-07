module CV::TlRule
  # ameba:disable Metrics/CyclomaticComplexity
  def fold_prepos_inner!(prepos : BaseNode, succ = prepos.succ?, mode = 0) : BaseNode
    return prepos unless (noun = scan_noun!(succ, mode: 0)) && noun.nounish?
    return fold!(prepos, noun, PosTag::PrepForm, dic: 2) unless verb = noun.succ?

    # combine with noun after ude1 if there exists verb right after
    if verb.pt_dep? && (tail = scan_noun!(verb.succ?))
      # TODO: combine this part with `fold_prepos_left`

      unless verb_2 = find_verb_after_for_prepos(tail, skip_comma: false)
        if tail.succ? { |x| x.boundary? || x.nounish? }
          noun = fold_ude1_left!(ude1: verb, left: noun, right: tail)
          return fold!(prepos, noun, PosTag::Vobj, dic: 9)
        end

        if prepos.pre_zai? && (noun = fold_prezai_locale?(prepos, noun, verb, tail))
          return fold!(prepos, noun, PosTag::PrepForm, dic: 3)
        end

        prepos = fold!(prepos, verb.set!(""), PosTag::PrepForm, dic: 5)
        return fold!(prepos, tail, PosTag::Nform, dic: 6, flip: true)
      end

      # puts [verb_2, verb, tail]

      fold_prepos_left(prepos, noun, ude1: verb, tail: tail).try { |x| return x }

      noun = fold_ude1_left!(ude1: verb, left: noun, right: tail)
      noun = fold_noun_after!(noun) unless verb_2.position?

      verb = noun.succ?
    end

    head = fold!(prepos, noun, PosTag::PrepForm, dic: 4)
    return head unless verb
    verb = heal_mixed!(verb) if verb.polysemy?

    case verb
    when .v_shi?, .v_you? then return head
    when .verbal?         then verb = fold_verbs!(verb)
    when .advbial?        then verb = fold_adverbs!(verb)
    else                       return head
    end

    return head unless verb.verbal?

    flip = false

    # fix prepos meaning
    case prepos.tag
    when .pre_zi4?  then prepos.val = "từ"
    when .pre_rang? then prepos.val = "khiến"
    when .pre_ling? then prepos.val = "làm" if head.prev?(&.content?)
    when .pre_gei3? then prepos.val = "làm" if head.prev?(&.content?)
    when .pre_dui?
      prepos.val = "với"
      flip = true
    end

    node = fold!(head, verb, verb.tag, dic: 8, flip: flip)
    return node unless (ude1 = node.succ?) && ude1.pt_dep?

    # if !node.verb_no_obj? && (prev = node.prev?) && prev.content?
    #   node = fold!(prev, node, PosTag::SubjVerb, dic: 7) unless mode == 3
    # end

    fold_ude1!(ude1: ude1, prev: node)
  end

  def fold_prepos_left(prepos : BaseNode, noun : BaseNode, ude1 : BaseNode, tail : BaseNode)
    # puts [prepos, noun, ude1, tail, prepos.prev?]

    case prepos.prev?
    when .nil?, .pro_dems?, .pro_ints?
      left = fold!(prepos, ude1.set!(""), PosTag::DcPhrase, dic: 6)
      fold!(left, tail, PosTag::Nform, dic: 9, flip: true)
    else
      # TODO
    end
  end
end
