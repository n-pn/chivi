module CV::TlRule
  def heal_suf_verb!(node : MtNode, succ : MtNode) : MtNode
    # TODO: handle special cases
    node.tag = PosTag::Verb
    node.fold!
  end

  def heal_suf_noun!(node : MtNode, succ : MtNode) : MtNode
    node.tag = PosTag::Noun
    node.fold!
  end

  def heal_suffix_们!(node : MtNode, succ : MtNode) : MtNode
    # TODO: update postag?
    node.fold!("các #{node.val}")
  end

  def heal_suffix_时!(node : MtNode, succ : MtNode) : MtNode
    node.tag = PosTag::Vintr
    node.fold!("lúc #{node.val}")
  end
end
