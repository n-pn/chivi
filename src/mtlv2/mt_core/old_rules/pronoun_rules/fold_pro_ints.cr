module MT::TlRule
  def fold_pro_ints!(proint : BaseNode, succ = node.succ?)
    if succ.is_a?(BaseTerm) && succ.polysemy?
      succ = heal_mixed!(succ)
    end

    case succ
    when .nil?, .v_shi?, .v_you?
      return proint
    when .verbal?
      succ = fold_verbs!(succ)
      return proint unless succ.verbal?
    when .noun_words?
      return proint unless succ = scan_noun!(succ)
    else
      return proint
    end

    flip = false

    case proint.key
    when "什么"
      flip = succ.noun_words?
      val = "gì"
    when "哪个"
      flip = succ.noun_words?
      val = "nào"
    when "怎么"
      val = "làm sao"
    end

    proint.set!(val) if val
    fold!(proint, succ, succ.tag, flip: flip)
  end
end
