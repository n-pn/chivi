module CV::TlRule
  def fold_verb_verb!(verb_1 : MtNode, verb_2 : MtNode) : MtNode
    if val = MTL::VERB_COMPLS[verb_2.key]?
      return fold!(verb_1, verb_2.set!(val), PosTag::Verb, dic: 6)
    end

    if can_combine_verb_verb?(verb_1)
      return fold!(verb_1, verb_2, verb_2.tag, dic: 7)
    end

    # TODO: add more cases

    verb_1
  end

  VERB_COMBINE = {"爱", "喜欢", "避免"}

  def can_combine_verb_verb?(verb : MtNode)
    verb.each do |node|
      return true if VERB_COMBINE.includes?(node.key)
    end

    verb.ends_with?('着')
  end
end
