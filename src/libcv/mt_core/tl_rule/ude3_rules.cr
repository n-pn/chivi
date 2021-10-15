module CV::TlRule
  def heal_ude3!(node : MtNode, succ = node.succ?)
    return unless succ

    case succ.tag
    when .verb?
      node.val = "phải"
      node = fold!(node, succ, succ.tag, 3)
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
        # return node
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

    node.tag = PosTag::Vphrase
    node
  end

  def fold_verb_ude2_succ!(node : MtNode, succ : MtNode, succ_2 : MtNode) : MtNode
    succ.val = ""
    fold!(node, succ, PosTag::Vphrase, 6)
  end
end
