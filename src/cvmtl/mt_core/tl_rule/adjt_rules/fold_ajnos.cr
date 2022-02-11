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
        MtDict.fix_adjt!(node)
      else
        MtDict.fix_noun!(node)
      end
    when .verbs?, .preposes?
      MtDict.fix_noun!(node)
    when .noun?
      node.set!(PosTag::Modifier)
    when .ude1?
      MtDict.fix_adjt!(node)
    else
      if {"到"}.includes?(succ.key)
        MtDict.fix_adjt!(node)
      else
        node
      end
    end
  end
end
