module CV::TlRule
  def fold_ajno!(node : MtNode)
    node = heal_ajno!(node)
    node.noun? ? fold_noun!(node) : fold_adjts!(node)
  end

  def heal_ajno!(node : MtNode)
    return node.set!(PosTag::Adjt) if node.prev?(&.adverbs?)

    case succ = node.succ?
    when .nil?, .ends?
      node.val = MtDict::CAST_NOUNS.fetch(node.key, node.val)
      node.set!(PosTag::Noun)
    when .ude1?
      node.set!(PosTag::Adjt)
    else
      node
    end
  end
end
