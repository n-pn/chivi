module CV::TlRule
  def heal_vead!(node : MtNode) : MtNode
    case succ = node.succ?
    when .nil?, .ends?
      return MtDict.fix_verb!(node)
    when .veno?
      succ = heal_veno!(succ)
      return succ.nominal? ? MtDict.fix_verb!(node) : MtDict.fix_adverb!(node)
    when .verbs?, .vmodals?, .preposes?
      return MtDict.fix_verb!(node)
    when .nominal?, .numeral?, .pronouns?
      return MtDict.fix_verb!(node)
    end

    case prev = node.prev?
    when .nil?    then node
    when .adverb? then MtDict.fix_verb!(node)
    when .nhanzi?
      prev.key == "一" ? MtDict.fix_verb!(node) : node
    else node
    end
  end
end
