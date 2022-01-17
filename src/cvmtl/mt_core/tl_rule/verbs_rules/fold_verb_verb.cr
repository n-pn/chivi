module CV::TlRule
  def fold_verb_verb!(verb_1 : MtNode, verb_2 : MtNode) : MtNode
    if val = MTL::VERB_COMPLS[verb_2.key]?
      return fold!(verb_1, verb_2.set!(val), PosTag::Verb, dic: 6)
    end

    return verb_1 unless can_combine_verb_verb?(verb_1)
    verb_2 = verb_2.adverbs? ? fold_adverbs!(verb_2) : fold_verbs!(verb_2)
    verb_2.verbs? ? fold!(verb_1, verb_2, verb_2.tag, dic: 7) : verb_1
    # TODO: add more cases
  end

  VERB_COMBINE = {"爱", "喜欢", "避免", "忍不住"}

  def can_combine_verb_verb?(verb : MtNode)
    verb.each do |node|
      return true if VERB_COMBINE.includes?(node.key)
    end

    verb.ends_with?('着')
  end
end
