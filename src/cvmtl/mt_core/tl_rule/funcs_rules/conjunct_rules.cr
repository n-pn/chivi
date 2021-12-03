module CV::TlRule
  def can_combine_adjt?(left : MtNode, right : MtNode?)
    return right.adjts?
  end

  def fold_adjt_concoord!(node : MtNode, prev = node.prev?, succ = node.succ?)
    return unless prev && succ

    unless succ.adjts?
      return
      # succ = scan_adjt!(succ)
      # return unless succ.adjts?
    end

    node.val = "và" if node.key == "和"
    fold!(prev, succ, tag: PosTag::Aform, dic: 4)
  end

  def fold_noun_concoord!(node : MtNode, prev = node.prev?, succ = node.succ?)
    return unless prev && succ

    unless similar_tag?(prev, succ)
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

  def similar_tag?(left : MtNode, right : MtNode)
    case left.tag
    when .nform? then true
    when .human? then right.human?
    when .noun?  then right.noun? || right.pro_dem?
    else
      right.nform? || right.tag == left.tag
    end
  end
end
