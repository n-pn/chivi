module CV::TlRule
  def fold_verb_verb!(verb_1 : MtNode, verb_2 : MtNode) : MtNode
    return fold!(verb_1, verb_2, verb_1.tag) if !verb_1.body? && verb_1.key == verb_2.key

    if val = MtDict::VERB_COMPLEMENT.get(verb_2.key)
      return fold!(verb_1, verb_2.set!(val), PosTag::Verb, dic: 6)
    end

    return verb_1 unless can_combine_verb_verb?(verb_1, verb_2.succ?)

    verb_2 = cast_verb!(verb_2) if verb_2.veno?
    verb_2.verbs? ? fold!(verb_1, verb_2, verb_2.tag, dic: 7) : verb_1
    # TODO: add more cases
  end

  VERB_COMBINE = {"爱", "喜欢", "避免", "忍不住"}

  def can_combine_verb_verb?(verb : MtNode, succ : MtNode?)
    verb.each do |node|
      return true if VERB_COMBINE.includes?(node.key)
    end

    is_linking_verb?(verb, succ)
  end
end
