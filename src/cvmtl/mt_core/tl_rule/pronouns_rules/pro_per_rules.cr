module CV::TlRule
  def fold_pro_per!(node : MtNode, succ : Nil) : MtNode
    node
  end

  def fold_pro_per!(node : MtNode, succ : MtNode) : MtNode
    # puts [node, succ, "proper"]

    case succ.tag
    when .concoord?, .penum?
      fold_noun_concoord!(succ, node) || node
    when .nouns?, .numbers?, .pro_per?, .pro_dem?
      succ = scan_noun!(succ)

      return node unless succ.nouns?
      return node unless noun_can_combine?(node.prev?, succ.succ?)
      fold_pro_per_noun!(node, succ)
    else
      # TODO: handle special cases
      node
    end
  end

  def fold_pro_per_noun!(node : MtNode, succ : MtNode) : MtNode
    case succ.tag
    when .space?
      fold_noun_space!(node, succ)
    when .place?
      fold_swap!(node, succ, PosTag::DefnPhrase, dic: 4)
    when .ptitle?
      fold_swap!(node, succ, succ.tag, dic: 4)
    when .names?
      # TODO: add pseudo node
      node.val = "của #{node.val}"
      fold_swap!(node, succ, succ.tag, dic: 4)
    else
      fold!(node, succ, PosTag::Nform, dic: 8)
    end
  end
end
