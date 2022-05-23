module CV::TlRule
  def fold_verb_verb!(verb_1 : MtNode, verb_2 : MtNode) : MtNode
    return verb_1 unless can_combine_verb_verb?(verb_1, verb_2)

    verb_2 = MtDict.fix_verb!(verb_2) if verb_2.veno?
    verb_2.verbal? ? fold!(verb_1, verb_2, verb_2.tag, dic: 5) : verb_1
    # TODO: add more cases
  end

  VERB_COMBINE = {"爱", "喜欢", "避免", "忍不住"}

  def can_combine_verb_verb?(verb : MtNode, verb_2 : MtNode)
    verb.each do |x|
      return true if VERB_COMBINE.includes?(x.key)
    end

    is_linking_verb?(verb, verb_2.succ?)
  end
end
