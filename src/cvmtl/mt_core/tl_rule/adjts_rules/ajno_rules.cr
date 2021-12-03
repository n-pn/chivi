module CV::TlRule
  def fold_ajno!(node : MtNode)
    if node.prev?(&.adverbs?)
      node.tag = PosTag::Adjt
    elsif !(succ = node.succ?) || succ.ends?
      node.tag = PosTag::Noun
    end

    if node.noun?
      node.val = MTL::AS_NOUNS.fetch(node.key, node.val)
      fold_noun!(node)
    else
      fold_adjts!(node)
    end
  end
end
