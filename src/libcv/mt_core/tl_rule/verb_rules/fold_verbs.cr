module CV::TlRule
  # - ameba:disable Metrics/CyclomaticComplexity
  def fold_verbs!(verb : MtNode, prev : MtNode? = nil) : MtNode
    verb = fold_adverb_node!(prev, verb) if prev

    # return verb if verb.flag.resolved?
    return fold_verb_object!(verb, verb.succ?) if verb.flag.checked?
    # puts [verb, prev].colorize.yellow

    return verb unless succ = verb.succ?

    fold_verb_compare(verb).try { |x| return x }

    case succ
    when .junction?
      if fold = fold_verb_junction!(junc: succ, verb: verb)
        verb = fold
      end
    when .suffixes?, .usuo?
      verb = fold_suffixes!(verb, succ)
      return verb unless succ = verb.succ?

      # TODO: link with adverb
      # when .adverb?
      #   if succ.key == "就" && (succ = fold_adverbs!(succ)) && succ.verbal?
      #     verb = fold!(verb, succ, succ.tag, dic: 9)
      #   end
    end

    return fold_uzhi!(uzhi: succ, prev: verb) if succ.uzhi?
    fold_verb_object!(verb, succ)
  end
end
