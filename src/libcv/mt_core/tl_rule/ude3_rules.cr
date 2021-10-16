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
    succ.val = ""

    case succ_2
    when .adverbs?
      succ_2 = fold_adverbs!(succ_2)
      if succ_2.adjts?
        return fold_verb_ude2_succ!(node, succ, succ_2)
      elsif succ_2.key == "很"
        succ_2.val = "cực kỳ"
        return fold_verb_ude2_succ!(node, succ, succ_2)
      else
        node
      end
    when .adjts?
      return fold_verb_ude2_succ!(node, succ, succ_2)
    when .verbs?
      node = fold!(node, succ, PosTag::Verb, 6)
      return fold_verb_compl!(node, succ_2) || node
    else
      # TODO: handle verb form
      node
    end
  end

  def fold_verb_ude2_succ!(node : MtNode, succ : MtNode, succ_2 : MtNode) : MtNode
    fold!(node, succ, PosTag::Vphrase, 6)
  end
end
