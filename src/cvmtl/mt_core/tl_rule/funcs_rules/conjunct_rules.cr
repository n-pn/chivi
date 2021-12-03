module CV::TlRule
  def nouns_can_group?(left : MtNode, right : MtNode)
    case left.tag
    when .human? then right.human?
    when .noun?  then right.noun? || right.pro_dem?
    else              right.tag == left.tag
    end
  end

  def can_combine_adjt?(left : MtNode, right : MtNode?)
    return right.adjts?
  end

  def heal_concoord!(node : MtNode)
    node.val = "và" if node.key == "和"
    node
  end

  def fold_noun_penum!(prev : MtNode, node : MtNode, succ = node.succ?)
  end

  def fold_noun_concoord!(prev : MtNode, node : MtNode, succ = node.succ?)
    return unless succ

    unless can_group?(prev, succ)
      succ = scan_noun!(succ)
      return unless succ.nouns?
    end

    if node.key == "和"
      if (tail = succ.succ?) && tail.maybe_verb?
        node = fold!(node, succ, PosTag::PrepPhrase, dic: 5)
        tail = fold_verbs!(tail)
        fold!(node, tail, tail.tag, dic: 6)

        # TOD: fold as subject + verb structure?
        return
      else
        node.val = "và"
      end
    end

    fold!(prev, succ, tag: PosTag::Nform, dic: 4)
  end

  def can_group?(left : MtNode, right : MtNode)
    case left.tag
    when .nform? then true
    when .human? then right.human?
    when .noun?  then right.noun? || right.pro_dem?
    else
      right.nform? || right.tag == left.tag
    end
  end
end
