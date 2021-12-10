module CV::TlRule
  def fold_ajno!(node : MtNode)
    node = heal_ajno!(node)
    node.noun? ? fold_noun!(node) : fold_adjts!(node)
  end

  def heal_ajno!(node : MtNode)
    return cast_adjt!(node) if node.prev?(&.adverbs?)

    case succ = node.succ?
    when .nil?, .ends?
      cast_noun!(node)
    when .ude1?
      cast_adjt!(node)
    else node
    end
  end
end
