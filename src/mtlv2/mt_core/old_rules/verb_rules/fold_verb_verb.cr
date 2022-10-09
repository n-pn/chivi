module MT::TlRule
  def fold_verb_verb!(verb_1 : BaseNode, verb_2 : BaseNode) : BaseNode
    return verb_1 unless verb_2.is_a?(BaseTerm)

    if verb_1.key == verb_2.key
      count = 0

      while succ = verb_2.succ?
        break unless succ.key == verb_1.key
        verb_2 = succ
        count += 1
      end

      tag = count == 0 ? verb_1.tag : MapTag::Verb
      return fold!(verb_1, verb_2, tag, dic: 0)
    end

    return verb_1 unless verb_1.tag.vauxil?
    fold!(verb_1, verb_2, verb_2.tag, dic: 5)
  end
end
