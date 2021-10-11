module CV::TlRule
  def heal_ude3!(node : MtNode, succ = node.succ?)
    return unless succ

    case succ.tag
    when .verb?
      node = node.fold!(succ, "phải #{succ.val}")
    else
      node.val = "được"
    end

    return fold_verbs!(node)
  end

  def fold_verb_ude3!(node : MtNode, succ : MtNode) : MtNode
    return node unless succ_2 = succ.succ?

    case succ_2
    when .special?
      case succ_2.key
      when "完"
        succ_2.val = "xong"
        return fold_verb_ude2_succ!(node, succ, succ_2)
      else
        return node
      end
    when .adverbs?
      succ_2 = fold_adverbs!(succ_2)
      if succ_2.adjts?
        return fold_verb_ude2_succ!(node, succ, succ_2)
      elsif succ_2.key == "很"
        succ_2.val = "cực kỳ"
        return fold_verb_ude2_succ!(node, succ, succ_2)
      end
    when .adjts?
      return fold_verb_ude2_succ!(node, succ, succ_2) if succ_2.adjts?
      # TODO: handle verb form
      # when .verbs?

    end

    node
  end

  def fold_verb_ude2_succ!(node : MtNode, succ : MtNode, succ_2 : MtNode) : MtNode
    node.tag = PosTag::Vform
    node.dic = 6
    node.val = "#{node.val} #{succ_2.val}"
    node.fold_many!(succ, succ_2)
  end
end
