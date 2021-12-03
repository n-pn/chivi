module CV::TlRule
  def fold_pro_per!(node : MtNode, succ : Nil) : MtNode
    node
  end

  def fold_pro_per!(node : MtNode, succ : MtNode) : MtNode
    case succ.tag
    when .space?
      fold_swap!(node, succ, PosTag::Place, dic: 4)
    when .place?
      fold_swap!(node, succ, PosTag::DefnPhrase, dic: 4)
    when .ptitle?
      return node unless should_not_combine_pro_per?(node.prev?, succ.succ?)
      fold_swap!(node, succ, succ.tag, dic: 4)
      # when .names?
      #   succ = fold_noun!(succ)
      #   return node unless succ.names?

      #   # TODO: add pseudo node
      #   node.val = "của #{node.val}"
      #   fold_swap!(node, succ, succ.tag, dic: 4)
    when .concoord?, .penum?
      fold_noun_concoord!(node, succ) || node
    else
      # TODO: handle special cases
      node
    end
  end
end
