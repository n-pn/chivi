module CV::TlRule
  # ameba:disable Metrics/CyclomaticComplexity
  def fold_verbs!(verb : MtNode, adverb : MtNode? = nil) : MtNode
    # puts [verb, adverb].colorize.yellow

    verb = fuse_verb!(verb) unless verb.verb_object?
    verb = fold_adverb_node!(adverb, verb) if adverb

    return verb.flag!(:resolved) unless succ = verb.succ?
    # puts [verb, succ]

    # TODO: link with adverb
    # if succ.adverb? && succ.key == "就" && (succ = fold_adverb_base!(succ)) && succ.verbal?
    #    verb = fold!(verb, succ, succ.tag, dic: 9)
    #  end

    unless verb.v0_obj? || succ.ude1? || succ.ends? || succ.junction?
      verb = fold_verb_object!(verb, succ)
      return verb.flag!(:resolved) unless succ = verb.succ?
    end

    case succ
    when .ude1?
      verb.v0_obj? && (tail = succ.succ?) ? fold_verb_ude1!(verb, succ, tail) : verb
    when .uzhi?
      fold_uzhi!(uzhi: succ, prev: verb)
    when .suffixes?
      fold_suffix!(base: verb, suff: succ)
    when .junction?
      fold_verb_junction!(junc: succ, verb: verb) || verb.flag!(:resolved)
    when .v_dircomp?
      # TODO: check
      MtDict.verb_dir.get_val(succ.key).try { |x| succ.val = x }
      fold!(verb, succ, verb.tag, dic: 5)
    else
      verb
    end
  end

  def fold_verb_ude1!(verb : MtNode, ude1 : MtNode, tail = ude1.succ)
    tail = fold_once!(tail)

    case tail
    when .object?
      ptag = PosTag::DefnPhrase
    when .adjective?
      ptag = PosTag::Adverb
    else
      ude1.set!("đấy", PosTag::Mopart)
      return verb
    end

    ude1.val = ""

    head = fold!(verb, ude1, ptag, dic: 1)
    fold!(head, tail, tail.tag, dic: 2, flip: true)
  end
end
