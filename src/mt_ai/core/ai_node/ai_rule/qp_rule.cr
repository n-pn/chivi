require "../ai_node"

module MT::AiRule
  def heal_qp!(dict : AiDict, node : AiNode, stem : String)
    return node unless m_node = node.find_by_cpos("M")

    if term = dict.get_special?(m_node.zstr, stem)
      m_node.set_vstr!(term.vstr)
    end

    node
  end
end
