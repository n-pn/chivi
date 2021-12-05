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
    # puts [noun, space, space.key, space.tag, "fold_noun_space"]
    return noun unless space && space.spaces?

    flip = true
    case space.key
    when "上", "下", "中"
      return noun if space.succ?(&.ule?)
      space.val = fix_space_val!(space)
    when "前"
      flip = !noun.time?
    end

    fold!(noun, space, PosTag::Place, dic: 5, flip: flip)
  end

  def fix_space_val!(node : MtNode)
    case node.tag
    when .v_shang? then "trên"
    when .v_xia?   then "dưới"
    else                node.key == "中" ? "trong" : node.val
    end
  end
end
