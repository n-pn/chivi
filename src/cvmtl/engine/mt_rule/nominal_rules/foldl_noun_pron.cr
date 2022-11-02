module MT::Rules
  def fold_noun_pron!(noun : MtNode, pron : MtNode)
    return fold_noun_per_pron!(noun, pron) if pron.per_prons?

    noun = NounExpr.new(noun) unless noun.is_a?(NounExpr)

    # FIXME: handle special pronoun cases
    noun.add_pdmod(pron)
    noun
  end

  def fold_noun_per_pron!(noun : MtNode, pron : MtNode)
    # FIXME: check for flips
    NounPair.new(pron, noun, flip: noun.honor?)
  end
end
