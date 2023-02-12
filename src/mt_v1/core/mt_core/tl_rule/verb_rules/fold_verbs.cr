module M1::TlRule
  # ameba:disable Metrics/CyclomaticComplexity
  def fold_verbs!(verb : MtNode, prev : MtNode? = nil) : MtNode
    return verb unless verb.verbal?
    return fold_verb_object!(verb, verb.succ?) if verb.is_a?(MtList)

    case verb
    when .v_shi?, .v_you?
      return fold_left_verb!(verb, prev)
    when .vpro?
      return verb unless (succ = verb.succ?) && succ.verbal?
      verb = fold!(verb, succ, succ.tag, dic: 5)
    when .vmodals?
      verb.tag = PosTag::Verb
    end

    flag = 0

    while !verb.verb_object? && (succ = verb.succ?)
      case succ
      when .junction?
        fold_verb_junction!(junc: succ, verb: verb).try { |x| verb = x } || break
      when .uzhe?
        verb = fold_verb_uzhe!(verb, uzhe: succ)
        break
      when .uyy?
        adjt = fold!(verb, succ.set!("như"), PosTag::Aform, dic: 7, flip: true)
        adjt = fold_adverb_node!(prev, adjt) if prev

        return adjt unless (succ = adjt.succ?) && succ.maybe_adjt?
        return adjt unless (succ = scan_adjt!(succ)) && succ.adjective?
        return fold!(adjt, succ, PosTag::Aform, dic: 8)
      when .auxils?
        verb = fold_verb_auxils!(verb, succ)
        break if verb.succ? == succ
      when .vdirs?
        verb = fold_verb_vdirs!(verb, succ)
        flag = 1
      when .adj_hao?
        case succ.succ?
        when .nil?, .ule?
          succ.val = "tốt"
        when .maybe_adjt?, .maybe_verb?, .preposes?
          break
        when .noun?
          break unless flag == 0
        else
          succ.val = "xong"
        end

        verb = fold!(verb, succ, PosTag::Verb, dic: 4)
      when .verbal?
        verb = fold_verb_verb!(verb, succ)
      when .adjective?, .preposes?, .specials?, .locat?
        break unless flag == 0
        fold_verb_compl!(verb, succ).try { |x| verb = x } || break
      when .adv_bu4?
        verb = fold_verb_advbu!(verb, succ)
      when .numeral?
        fold_verb_compare(verb).try { |x| return x }

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

        verb = fold_verb_nquant!(verb, succ)
        prev = nil
        break
      else
        break
      end

      break if verb.succ? == succ
    end

    verb = fold_adverb_node!(prev, verb) if prev
    return verb unless succ = verb.succ?

    fold_verb_compare(verb).try { |x| return x }

    return fold_uzhi!(uzhi: succ, prev: verb) if succ.uzhi?
    fold_verb_object!(verb, succ)
  end
end
