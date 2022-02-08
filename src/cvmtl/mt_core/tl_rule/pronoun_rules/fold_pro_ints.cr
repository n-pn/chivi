module CV::TlRule
  def fold_pro_ints!(proint : MtNode, succ = node.succ?)
    case succ
    when .nil?, .v_shi?, .v_you?
      return proint
    when .veno?
      succ = fold_verbs!(cast_verb!(succ))
    when .verbs?
      succ = fold_verbs!(succ)
    when .nouns?
      return proint unless succ = scan_noun!(succ)
    else
      return proint
    end

    flip = false

    case proint.key
    when "什么"
      proint.set!("gì")
      flip = true
    when "怎么"
      flip = true
    when "哪个"
      return proint unless succ.nouns?
    end

    fold!(proint, succ, succ.tag, dic: 3, flip: flip)
  end
end
