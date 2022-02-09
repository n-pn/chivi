module CV::TlRule
  def fold_verbs!(verb : MtNode, prev : MtNode? = nil) : MtNode
    return fold_verb_object!(verb, verb.succ?) if verb.body?
    # puts [verb, prev].colorize.yellow

    case verb
    when .v_shi?, .v_you?
      return fold_left_verb!(verb, prev)
    when .vpro?
      return verb unless (succ = verb.succ?) && succ.verbs?
      verb = fold!(verb, succ, succ.tag, dic: 5)
    when .vmodals?
      verb.tag = PosTag::Verb
    end

    head = verb
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
        return adjt unless (succ = scan_adjt!(succ)) && succ.adjts?
        return fold!(adjt, succ, PosTag::Aform, dic: 8)
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
      when .verbs?
        verb = fold_verb_verb!(verb, succ)
      when .adjts?, .preposes?, .uniques?, .space?
        break unless flag == 0
        fold_verb_compl!(verb, succ).try { |x| verb = x } || break
      when .adv_bu?
        verb = fold_verb_advbu!(verb, succ)
      when .numeric?
        case head.key
        when "如", "像", "好像", "仿佛"
          fold_compare(verb).try { |x| return x }
        end

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
    end

    verb = fold_adverb_node!(prev, verb) if prev
    return verb unless succ = verb.succ?

    case head.key
    when "如", "像", "好像", "仿佛"
      fold_compare(verb).try { |x| return x }
    end

    case succ
    when .suf_noun?, .usuo?
      verb = fold_suf_noun!(verb, succ)
      return verb unless succ = verb.succ?

      # TODO: link with adverb
      # when .adverb?
      #   if succ.key == "就" && (succ = fold_adverbs!(succ)) && succ.verbs?
      #     verb = fold!(verb, succ, succ.tag, dic: 9)
      #   end
    end

    return fold_uzhi!(uzhi: succ, prev: verb) if succ.uzhi?
    fold_verb_object!(verb, succ)
  end
end
