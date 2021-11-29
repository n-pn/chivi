module CV::TlRule
  def fold_space!(node : MtNode) : MtNode
    if (prev = node.prev?) && (prev.nouns? || prev.pro_per?)
      node = fold_noun_space!(prev, node)
      return fold_noun_left!(node)
    end

    case node.key
    when "中"
      node.set!("trúng", PosTag::Verb)
      fold_verbs!(node)
    when "右", "左"
      node.tag = PosTag::Modifier
      fold_modifier!(node)
    else
      node
    end
  end
end
