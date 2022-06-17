module MtlV2::TlRule
  def fold_adverb_node!(adv : BaseNode, node = adv.succ, tag = node.tag) : BaseNode
    flip = false

    case adv.key
    when "不太"
      # TODO: just delete this entry
      head = BaseNode.new("不", "không", PosTag::AdvBu4, 1, adv.idx)
      tail = BaseNode.new("太", "lắm", PosTag::Adverb, 1, adv.idx + 1)

      node.set_prev!(head)
      node.set_succ!(tail)

      return fold!(head, tail, tag, dic: 4)
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

    fold!(adv, node, tag, dic: 4, flip: flip)
    # node
  end
end
