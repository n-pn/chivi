module CV::TlRule
  def fold_space!(node : MtNode) : MtNode
    if (prev = node.prev?) && (prev.nouns? || prev.pro_per?)
      return fold_noun_space!(prev, node)
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

  def fold_noun_space!(noun : MtNode, space = noun.succ?) : MtNode
    return noun unless space && space.space?
    # puts [noun, space, "fold_noun_space"]

    space.val = MTL::FIX_SPACES[space.key]? || space.val

    if noun.time? && {"前"}.includes?(space.key)
      fold!(noun, space, PosTag::Place, dic: 5)
    else
      fold_swap!(noun, space, PosTag::Place, dic: 4)
    end
  end
end
