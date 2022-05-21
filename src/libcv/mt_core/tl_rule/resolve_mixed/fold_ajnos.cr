module CV::TlRule
  def fold_ajno!(node : MtNode)
    case node = heal_ajno!(node)
    when .verb? then fold_verbs!(node)
    when .noun? then fold_nouns!(node)
    else             fold_adjts!(node)
    end
  end

  def heal_ajno!(node : MtNode)
    case node.prev?
    when .nil?
    when .adverbial?
      return MtDict.fix_adjt!(node)
    when .modifier?
      return MtDict.fix_noun!(node)
    end

    # puts [node, node.prev?, node.succ?]
    case succ = node.succ?
    when .nil?, .puncts?
      if node.prev?(&.object?)
        MtDict.fix_adjt!(node)
      else
        MtDict.fix_noun!(node)
      end
    when .vdir?
      MtDict.fix_verb!(node)
    when .verbs?, .preposes?, .none?, .spaces?
      MtDict.fix_noun!(node)
    when .noun?
      node.set!(PosTag::Modifier)
    when .ude1?, .mopart?
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
