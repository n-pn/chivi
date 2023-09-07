module MT::AiRule
  def heal_advp!(dict : AiDict, node : AiNode) : AiNode
    node.add_attr!(node.last.attr)
    node
  end
end
