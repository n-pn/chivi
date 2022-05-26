module CV::TlRule
  # - ameba:disable Metrics/CyclomaticComplexity
  def fold_verbs!(verb : MtNode, prev : MtNode? = nil) : MtNode
    # puts [verb, prev].colorize.yellow

    verb = fuse_verb!(verb)
    verb = fold_adverb_node!(prev, verb) if prev

    return verb.flag!(:resolved) unless succ = verb.succ?

    # puts [verb, succ]

    # TODO: link with adverb
    # if succ.adverb? && succ.key == "就" && (succ = fold_adverb_base!(succ)) && succ.verbal?
    #    verb = fold!(verb, succ, succ.tag, dic: 9)
    #  end

    if succ.junction? && (fold = fold_verb_junction!(junc: succ, verb: verb))
      verb = fold
      return verb.flag!(:resolved) unless succ = verb.succ?
    end

    return fold_uzhi!(uzhi: succ, prev: verb) if succ.uzhi?
    fold_verb_object!(verb, succ)
  end
end
