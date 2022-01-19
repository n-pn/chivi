module CV::TlRule
  def fold_ajno!(node : MtNode)
    node = heal_ajno!(node)
    node.noun? ? fold_nouns!(node) : fold_adjts!(node)
  end

  def heal_ajno!(node : MtNode)
    # puts [node, node.prev?, node.succ?]
    case succ = node.succ?
    when .nil?, .puncts?
      if node.prev?(&.object?)
        cast_adjt!(node)
      else
        cast_noun!(node)
      end
    when .verbs?, .preposes?
      cast_noun!(node)
    when .noun?
      node.set!(PosTag::Modifier)
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
