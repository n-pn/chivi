module CV::TlRule
  def heal_ude3!(node : MtNode, succ = node.succ?)
    return unless succ

    case succ.tag
    when .verb?
      node.val = "phải"
      node = fold!(node, succ, succ.tag, 6)
    else
      node.val = "được"
    end

    fold_verbs!(node)
  end

  def fold_verb_ude3!(node : MtNode, succ : MtNode) : MtNode
    return node unless succ_2 = succ.succ?
    succ.val = ""

    case succ_2
    when .adverbs?
      succ_2 = fold_adverbs!(succ_2)

      if succ_2.adjts?
        fold!(node, succ_2, PosTag::Vphrase, 5)
      elsif succ_2.key == "很"
        succ_2.val = "cực kỳ"
        fold!(node, succ_2, PosTag::Vphrase, 5)
      else
        node
      end
    when .adjts?
      fold!(node, succ_2, PosTag::Vphrase, 6)
    when .verbs?
      node = fold!(node, succ, PosTag::Verb, 6)
      return fold_verb_compl!(node, succ_2) || node
    else
      # TODO: handle verb form
      node
    end
  end
end
