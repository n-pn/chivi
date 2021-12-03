module CV::TlRule
  def fold_verb_nquant!(verb : MtNode, node : MtNode, has_ule = false)
    node = fold_numbers!(node) if node.numbers?
    return verb unless node.nquants?

    if node.nqiffy? || node.nqnoun?
      return verb if node.succ?(&.nouns?) || has_ule
      return verb unless is_temp_nqverb?(node)
    end

    return fold!(verb, node, PosTag::VerbPhrase, dic: 6)
  end

  def is_temp_nqverb?(node : MtNode)
    case node.key[-1]?
    when "把"
      node.val = node.val.sub("bả", "phát")
    when "脚", "口", "眼", "圈"
      true
    else
      false
    end
  end
end
