module M1::TlRule
  def fold_adverb_node!(adv : MtNode, node = adv.succ, tag = node.tag, dic = 4) : MtNode
    flip = false

    case adv.key
    when "最", "最为", "那么", "这么", "非常", "如此"
      flip = true
    when "好好"
      adv.val = "cho tốt"
      flip = true
    when "十分"
      adv.val = "vô cùng"
      flip = true
    when "挺"
      adv.val = "rất"
    end

    fold!(adv, node, tag, dic: dic, flip: flip)
  end
end
