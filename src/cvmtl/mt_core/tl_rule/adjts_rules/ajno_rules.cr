module CV::TlRule
  def fold_ajno!(node : MtNode)
    node = heal_ajno!(node)
    node.noun? ? fold_nouns!(node) : fold_adjts!(node)
  end

  def heal_ajno!(node : MtNode)
    case succ = node.succ?
    when .nil?, .ends?, .verbs?, .preposes?, .noun?
      cast_noun!(node)
    when .ude1?
      cast_adjt!(node)
    else
      if {"到"}.includes?(succ.key)
        cast_adjt!(node)
      else
        node
      end
    end
  end
end
