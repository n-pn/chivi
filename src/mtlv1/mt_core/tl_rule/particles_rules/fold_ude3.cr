module CV::TlRule
  def heal_ude3!(node : MtNode, succ = node.succ?) : MtNode
    return node unless succ

    if succ.verbal? && succ.key != "到"
      node = fold!(node.set!("phải"), succ, succ.tag, dic: 6)
    else
      node.val = "được"
    end

    fold_verbs!(node)
  end

  def fold_adverb_ude3!(node : MtNode, succ : MtNode) : MtNode
    case tail = succ.succ?
    when .nil?
      fold!(node, succ.set!("phải"), PosTag::Adverb, dic: 4)
    when .key_is?("住")
      succ.val = ""
      node = MtDict.fix_verb!(node) if node.is_a?(MtTerm)
      fold!(node, tail.set!("nổi"), PosTag::Verb, dic: 5)
    when .verbal?
      node = fold!(node, succ.set!("phải"), PosTag::Adverb, dic: 4)
      fold_verbs!(tail, prev: node)
    else
      # TODO: add case here
      fold!(node, succ.set!("phải"), PosTag::Adverb, dic: 4)
    end
  end

  def fold_verb_ude3!(node : MtNode, succ : MtNode) : MtNode
    return node unless tail = succ.succ?
    succ.val = ""

    case tail
    # when .pre_bi3?
    # tail = fold_compare_bi3!(tail)
    # fold!(node, tail, PosTag::Vobj, dic: 7)
    when .advbial?
      tail = fold_adverbs!(tail)

      if tail.adjts?
        fold!(node, tail, PosTag::Aform, dic: 5)
      elsif tail.key == "很"
        tail.val = "cực kỳ"
        fold!(node, tail, PosTag::Aform, dic: 5)
      elsif tail.verbal?
        succ.set!("đến")
        fold!(node, tail, tail.tag, dic: 8)
      else
        node
      end
    when .adjts?
      fold!(node, tail, PosTag::Aform, dic: 6)
    when .verbal?
      node = fold!(node, succ, PosTag::Verb, dic: 6)
      fold_verb_compl!(node, tail) || node
    else
      # TODO: handle verb form
      node
    end
  end
end
