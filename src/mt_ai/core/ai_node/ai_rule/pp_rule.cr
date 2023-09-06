module MT::AiRule
  def heal_pp!(dict : AiDict, node : AiNode, stem : String) : AiNode
    return node unless p_node = node.find_by_cpos("P")
    node.add_prop!(p_node.prop)

    if term = AiDict.get_special?(p_node.zstr, stem)
      p_node.set_vstr!(term.vstr)
      p_node.add_prop!(term.prop)
    end

    node
  end
end
