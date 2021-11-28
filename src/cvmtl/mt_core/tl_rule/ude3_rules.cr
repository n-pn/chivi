module CV::TlRule
  def heal_ude3!(node : MtNode, succ = node.succ?) : MtNode
    return node unless succ

    case succ.tag
    when .verbs?
      node.val = "phải"
      node = fold!(node, succ, succ.tag, dic: 6)
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
        fold!(node, succ_2, PosTag::VerbPhrase, dic: 5)
      elsif succ_2.key == "很"
        succ_2.val = "cực kỳ"
        fold!(node, succ_2, PosTag::VerbPhrase, dic: 5)
      else
        node
      end
    when .adjts?
      fold!(node, succ_2, PosTag::VerbPhrase, dic: 6)
    when .verbs?
      node = fold!(node, succ, PosTag::Verb, dic: 6)
      return fold_verb_compl!(node, succ_2) || node
    else
      # TODO: handle verb form
      node
    end
  end
end
