module CV::TlRule
  def heal_ude3!(node : MtNode, succ = node.succ?) : MtNode
    return node unless succ

    if succ.verbs? && succ.key != "到"
      node = fold!(node.set!("phải"), succ, succ.tag, dic: 6)
    else
      node.val = "được"
    end

    fold_verbs!(node)
  end

  def fold_verb_ude3!(node : MtNode, succ : MtNode) : MtNode
    return node unless tail = succ.succ?
    succ.val = ""

    case tail
    when .pre_bi3?
      tail = fold_compare_bi3!(tail)
      fold!(node, tail, PosTag::VerbObject, dic: 7)
    when .adverbs?
      tail = fold_adverbs!(tail)

      if tail.adjts?
        fold!(node, tail, PosTag::Aform, dic: 5)
      elsif tail.key == "很"
        tail.val = "cực kỳ"
        fold!(node, tail, PosTag::Aform, dic: 5)
      elsif tail.verbs?
        succ.set!("đến")
        fold!(node, tail, tail.tag, dic: 8)
      else
        node
      end
    when .adjts?
      fold!(node, tail, PosTag::Aform, dic: 6)
    when .verbs?
      node = fold!(node, succ, PosTag::Verb, dic: 6)
      fold_verb_compl!(node, tail) || node
    else
      # TODO: handle verb form
      node
    end
  end
end
