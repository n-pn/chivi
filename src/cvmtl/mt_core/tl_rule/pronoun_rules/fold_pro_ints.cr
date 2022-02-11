module CV::TlRule
  def fold_pro_ints!(proint : MtNode, succ = node.succ?)
    case proint.key
    when "什么"
      val = "gì"
    when "哪个"
      val = "nào"
    when "怎么"
      val = "thế nào"
    else
      return proint
    end

    flip = true

    case succ
    when .nil?, .v_shi?, .v_you?
      return proint
    when .veno?
      succ = fold_verbs!(MtDict.fix_verb!(succ))
    when .verbs?
      succ = fold_verbs!(succ)
    when .nouns?
      return proint unless succ = scan_noun!(succ)
    else
      return proint
    end

    proint.set!(val) if val
    fold!(proint, succ, succ.tag, dic: 3, flip: flip)
  end
end
