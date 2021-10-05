module CV::TlRule
  def fold_verbs!(node : MtNode, succ = node.succ?, nega : MtNode? = nil)
    # TODO: fold verbs
    node.fold_left!(nega)
  end
end
