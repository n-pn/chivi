module CV::TlRule
  def fold_adjts!(node : MtNode, succ = node.succ?, nega : MtNode? = nil)
    # TODO: combine with nouns
    node.fold_left!(nega)
  end

  def fold_modifier!(node : MtNode, succ = node.succ?, nega : MtNode? = nil)
    # TODO: combine with nouns
    node.fold_left!(nega)
  end
end
