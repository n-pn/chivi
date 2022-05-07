module CV::TlRule
  def fold_verb_verb!(verb_1 : MtNode, verb_2 : MtNode) : MtNode
    if verb_1.key == verb_2.key
      count = 0

      while succ = verb_2.succ?
        break unless succ.key == verb_1.key
        verb_2 = succ
        count += 1
      end

      tag = count == 0 ? verb_1.tag : PosTag::None
      return fold!(verb_1, verb_2, tag, dic: 0)
    end

    if MtDict.fix_vcompl(verb_2)
      return fold!(verb_1, verb_2, PosTag::Verb, dic: 6)
    end

    return verb_1 unless can_combine_verb_verb?(verb_1, verb_2)

    verb_2 = MtDict.fix_verb!(verb_2) if verb_2.veno?
    verb_2.verbs? ? fold!(verb_1, verb_2, verb_2.tag, dic: 5) : verb_1
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
