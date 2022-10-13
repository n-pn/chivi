module MT::TlRule
  # ameba:disable Metrics/CyclomaticComplexity
  def fold_verbs!(verb : MtNode, prev : MtNode? = nil) : MtNode
    return verb unless verb.verb_words?
    return fold_verb_object!(verb, verb.succ?) if verb.is_a?(BaseList)

    case verb
    when .v_shi?, .v_you?
      return fold_left_verb!(verb, prev)
    when .vpro?
      return verb unless (succ = verb.succ?) && succ.verb_words?
      verb = fold!(verb, succ, succ.tag)
    when .modal_verbs?
      verb.tag = MapTag::Verb
    end

    flag = 0

    while !verb.vobj? && (succ = verb.succ?)
      case succ
      when .bond_word?
        fold_verb_junction!(junc: succ, verb: verb).try { |x| verb = x } || break
      when .pt_zhe?
        verb = fold_verb_uzhe!(verb, uzhe: succ)
        break
      when .pt_cmps?
        adjt = fold!(verb, succ.set!("như"), MapTag::Aform, flip: true)
        adjt = fold_adverb_node!(prev, adjt) if prev

        return adjt unless (succ = adjt.succ?) && succ.maybe_adjt?
        return adjt unless (succ = scan_adjt!(succ)) && succ.adjt_words?
        return fold!(adjt, succ, MapTag::Aform)
      when .particles?
        verb = fold_verb_auxils!(verb, succ)
        break if verb.succ? == succ
      when .vdir?
        verb = fold_verb_vdirs!(verb, succ)
        flag = 1
      when .wd_hao?
        case succ.succ?
        when .nil?, .pt_le?
          succ.val = "tốt"
        when .maybe_adjt?, .maybe_verb?, .preposes?
          break
        when .common_nouns?
          break unless flag == 0
        else
          succ.val = "xong"
        end

        verb = fold!(verb, succ, MapTag::Verb)
      when .verb_words?
        verb = fold_verb_verb!(verb, succ)
        # when .adjt_words?, .preposes?, .locat?
        #   break unless flag == 0
        #   fold_verb_compl!(verb, succ).try { |x| verb = x } || break
      when .adv_bu4?
        verb = fold_verb_advbu!(verb, succ)
      when .qtverb?, .qttime?
        verb = fold!(verb, succ, verb.tag)
        break
      else
        break
      end

      break if verb.succ? == succ
    end

    verb = fold_adverb_node!(prev, verb) if prev
    return verb unless succ = verb.succ?

    fold_verb_compare(verb).try { |x| return x }

    return fold_uzhi!(uzhi: succ, prev: verb) if succ.pt_zhi?
    fold_verb_object!(verb, succ)
  end
end
