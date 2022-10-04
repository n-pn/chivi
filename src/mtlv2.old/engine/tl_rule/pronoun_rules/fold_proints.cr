module MtlV2::TlRule
  def fold_pro_ints!(proint : BaseNode, succ = node.succ?)
    case succ
    when .nil?, .v_shi?, .v_you?
      return proint
    when .pl_veno?
      succ = fold_verbs!(MtDict.fix_verb!(succ))
    when .verbal?
      succ = fold_verbs!(succ)
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
