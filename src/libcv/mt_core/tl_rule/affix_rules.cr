module CV::TlRule
  def fold_suf_noun!(node : MtNode, succ : MtNode) : MtNode
    node.tag = PosTag::Noun # unless node.tag.nouns?
    succ.val = "các" if succ.suffix_men?

    # TODO: handle special cases
    return node.fold!(succ, val: "#{succ.val} #{node.val}", dic: 6)
  end

  def fold_suf_verb!(node : MtNode, succ : MtNode) : MtNode
    # TODO: handle special cases
    node.tag = PosTag::Verb
    return node.fold!(succ, val: "#{succ.val} #{node.val}", dic: 6)
  end

  # 们
  def fold_suf_men!(node : MtNode, succ : MtNode) : MtNode
    node.tag = PosTag::Noun
    node.fold!(succ, "các #{node.val}")
  end

  # 时
  def fold_suf_shi!(node : MtNode, succ : MtNode) : MtNode
    node.tag = PosTag::Noun
    node.fold!(succ, "lúc #{node.val}")
  end
end
