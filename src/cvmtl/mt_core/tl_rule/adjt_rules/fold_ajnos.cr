module CV::TlRule
  def fold_ajno!(node : MtNode)
    node = heal_ajno!(node)
    node.noun? ? fold_nouns!(node) : fold_adjts!(node)
  end

  def heal_ajno!(node : MtNode)
    # puts [node, node.prev?, node.succ?]
    case succ = node.succ?
    when .nil?, .puncts?
      node.prev?(&.subject?) ? cast_adjt!(node) : cast_noun!(node)
    when .verbs?, .preposes?, .nouns?
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
