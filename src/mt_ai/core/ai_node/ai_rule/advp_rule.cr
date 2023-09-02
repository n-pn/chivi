module MT::AiRule
  def heal_advp!(dict : AiDict, node : AiNode) : AiNode
    node.add_pecs!(node.last.pecs)

    node
  end
end
