module M1::TlRule
  def fold_space!(node : MtNode) : MtNode
    case node.key
    when "中"
      node.set!("trúng", PosTag::Verb)
      fold_verbs!(node)
    when "右", "左"
      node.tag = PosTag::Modi
      fold_modifier!(node)
    else
      node
    end
  end

  def fold_noun_space!(noun : MtNode) : MtNode
    return noun unless (space = noun.succ?) && space.spaces?
    fold_noun_space!(noun, space)
  end

  def fold_noun_space!(noun : MtNode, space : MtNode) : MtNode
    # puts [noun, space, "noun_space"]

    flip = true
    case space.key
    when "上", "下"
      return noun if noun.human? || space.succ?(&.ule?)
      space.val = fix_space_val!(space)
    when "中"
      return noun if space.succ?(&.ule?)
      space.val = "trong"
      if (succ = space.succ?) && succ.nominal?
        return fold!(noun, succ, PosTag::NounPhrase, dic: 6, flip: true)
      end
    when "前"
      # space.val = "trước khi" if noun.verbal?
      flip = !noun.ntime?
    end

    fold!(noun, space, PosTag::Posit, dic: 5, flip: flip)
  end

  def fix_space_val!(node : MtNode)
    case node.tag
    when .v_shang? then "trên"
    when .v_xia?   then "dưới"
    else                node.key == "中" ? "trong" : node.val
    end
  end
end
