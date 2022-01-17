module CV::TlRule
  def fold_verbs!(verb : MtNode, prev : MtNode? = nil) : MtNode
    # puts [verb, prev].colorize.yellow

    case verb
    when .v_shi?, .v_you?
      return fold_left_verb!(verb, prev)
    when .vpro?
      return verb unless (succ = verb.succ?) && succ.verbs?
      verb = fold!(verb, succ, succ.tag, dic: 5)
    end

    flag = 0

    while !verb.verb_object? && (succ = verb.succ?)
      # puts [verb, verb.idx, succ]

      case succ
      when .junction?
        fold_verb_junction!(junc: succ, verb: verb).try { |x| verb = x } || break
      when .uzhe?
        verb = fold_verb_uzhe!(verb, uzhe: succ)
        break
      when .auxils?
        verb = fold_verb_auxils!(verb, succ)
        break if verb.succ? == succ
      when .vdirs?
        verb = fold_verb_vdirs!(verb, succ)
        flag = 1
      when .adj_hao?
        break unless flag == 0 || succ.succ?(&.noun?)
        succ.val = "xong" unless succ.succ?(&.ule?)
        verb = fold!(verb, succ, PosTag::Verb, dic: 4)
      when .adjts?, .verbs?, .preposes?, .uniques?, .space?
        break unless flag == 0
        fold_verb_compl!(verb, succ).try { |x| verb = x } || break
      when .adv_bu?
        verb = fold_verb_advbu!(verb, succ)
      when .numeric?
        if succ.key == "一" && (succ_2 = succ.succ?) && succ_2.key == verb.key
          verb = fold!(verb, succ_2.set!("phát"), verb.tag, dic: 6)
          break # TODO: still keep folding?
        end

        if val = PRE_NUM_APPROS[verb.key]?
          succ = fold_number!(succ) if succ.numbers?

          verb = fold_left_verb!(verb.set!(val), prev)
          return verb unless succ.nquants?
          return fold!(verb, succ, succ.tag, dic: 8)
        end

        verb = fold_verb_nquant!(verb, succ, prev)
        prev = nil
        break
      else
        break
      end

      break if verb.succ? == succ
      verb.set!(PosTag::Verb) unless verb.vintr?
    end

    fold_adverb_node!(prev, verb) if prev
    return verb unless succ = verb.succ?

    if succ.suf_noun? || succ.usuo?
      verb = fold_suf_noun!(verb, succ)
      return verb unless succ = verb.succ?
    end

    return fold_uzhi!(uzhi: succ, prev: verb) if succ.uzhi?
    return verb if verb.verb_object? || verb.vintr?

    return verb unless (noun = scan_noun!(succ)) && noun.subject?

    if (ude1 = noun.succ?) && ude1.ude1? && should_apply_ude1_after_verb?(verb)
      noun = fold_ude1!(ude1, prev: noun)
    end

    fold!(verb, noun, PosTag::VerbObject, dic: 7)
  end
end