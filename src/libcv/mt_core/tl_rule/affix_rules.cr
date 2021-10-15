module CV::TlRule
  def fold_suf_noun!(node : MtNode, succ : MtNode) : MtNode
    # TODO: handle special cases
    succ.val = "các" if succ.suffix_men?
    fold_swap!(node, succ, PosTag::Noun, dic: 7)
  end

  def fold_suf_verb!(node : MtNode, succ : MtNode) : MtNode
    # TODO: handle special cases
    fold_swap!(node, succ, PosTag::Verb, dic: 7)
  end

  def fold_suf_men!(node : MtNode, succ : MtNode) : MtNode
    fold_suf_noun!(node, succ)
  end

  # 时
  def fold_suf_shi!(node : MtNode, succ : MtNode) : MtNode
    fold_suf_noun!(node, succ)
  end
end
