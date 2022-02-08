module CV::TlRule
  def fold_pro_ints!(proint : MtNode, succ : MtNode)
    case succ
    when .nouns?
      return proint unless succ = scan_noun!(succ)
    when .v_shi?, .v_you?
      return proint
    when .verbs?
      succ = fold_verbs!(succ)
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
    end

    fold!(proint, succ, succ.tag, dic: 3, flip: flip)
  end
end
