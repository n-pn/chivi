module MT::AiRule
  def heal_advp!(dict : AiDict, node : AiNode) : AiNode
    node.add_prop!(node.last.prop)

    node
  end
end
