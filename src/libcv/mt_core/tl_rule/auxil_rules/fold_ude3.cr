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
    when .key?("住")
      succ.val = ""
      fold!(MtDict.fix_verb!(node), tail.set!("nổi"), PosTag::Verb, dic: 5)
    when .verbal?
      node = fold!(node, succ.set!("phải"), PosTag::Adverb, dic: 4)
      fold_verbs!(tail, prev: node)
    else
      # TODO: add case here
      fold!(node, succ.set!("phải"), PosTag::Adverb, dic: 4)
    end
  end
end
