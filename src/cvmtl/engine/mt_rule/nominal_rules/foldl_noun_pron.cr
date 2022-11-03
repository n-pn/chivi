module MT::Rules
  def fold_noun_pron!(noun : MtNode, pron : MtNode)
    return fold_noun_per_pron!(noun, pron) if pron.per_prons?

    noun = NounExpr.new(noun) unless noun.is_a?(NounExpr)

    fix_pronoun_val_as_modi!(pron, noun)
    noun.add_pdmod(pron)
    noun
  end

  def fix_pronoun_val_as_modi!(pron, noun)
    # FIXME: handle special pronoun cases
    return unless pron.is_a?(MonoNode)
    case pron.key
    when "什么" then pron.val = "gì"
    end
  end

  def fold_noun_per_pron!(noun : MtNode, pron : MtNode)
    if !pron.prev?(&.vtwo?) || noun.succ?(&.common_nouns?)
      # FIXME: check for sentence with two subj+predicate forms
      return NounPair.new(pron, noun, noun.tag, noun.pos, flip: true)
    end

    if noun.is_a?(NounPair) && noun.head.humankind?
      noun_head, noun_tail = noun.detach!
      pron = NounPair.new(pron, noun_head, noun_head.tag, noun_head.pos, flip: true)
      NounPair.new(pron, noun_tail, noun_tail.tag, noun_tail.pos, flip: false)
    else
      NounPair.new(pron, noun, noun.tag, noun.pos, flip: true)
    end
  end
end
