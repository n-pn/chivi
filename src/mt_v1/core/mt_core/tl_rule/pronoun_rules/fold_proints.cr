module M1::TlRule
  def fold_pro_ints!(proint : MtNode, succ = node.succ?)
    if succ.is_a?(MtDefn) && succ.polysemy?
      succ = heal_mixed!(succ)
    end

    case succ
    when .nil?, .v_shi?, .v_you?
      return proint
    when .verbal?
      succ = fold_verbs!(succ)
      return proint unless succ.verbal?
    when .nominal?
      return proint unless succ = scan_noun!(succ)
    else
      return proint
    end

    flip = false

    case proint.key
    when "什么"
      flip = succ.nominal?
      val = "gì"
    when "哪个"
      flip = succ.nominal?
      val = "nào"
    when "怎么"
      val = "làm sao"
    end

    proint.set!(val) if val
    fold!(proint, succ, succ.tag, dic: 3, flip: flip)
  end
end
