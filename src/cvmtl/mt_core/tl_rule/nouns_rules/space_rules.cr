module CV::TlRule
  FIX_SPACES = {
    "上"  => "trên",
    "下"  => "dưới",
    "之前" => "trước",
  }

  def fold_noun_space!(node : MtNode, succ = node.succ?) : MtNode
    return node unless succ

    succ.val = FIX_SPACES[succ.key]? || succ.val
    fold_swap!(node, succ, PosTag::Place, dic: 4)
  end
end
