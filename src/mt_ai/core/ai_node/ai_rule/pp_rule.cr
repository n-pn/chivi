module MT::AiRule
  def heal_pp!(dict : AiDict, node : AiNode, v_node : AiNode) : AiNode
    return node unless p_node = node.find_by_epos(MtEpos::P)
    MtPair.p_v_pair.fix_if_match!(p_node, v_node)

    node.add_attr!(p_node.attr)
    node
  end
end
