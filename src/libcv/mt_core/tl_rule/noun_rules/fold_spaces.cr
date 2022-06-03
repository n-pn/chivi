module CV::TlRule
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

  def fold_noun_locality!(noun : MtNode, locality : MtNode) : MtNode
    # puts [noun, locality, "noun_locality"]

    flip = true

    case locality.key
    when "上", "下", "中"
      return noun if noun.human?
    when "前"
      # locality.val = "trước khi" if noun.verbal?
      flip = !noun.temporal?
    end

    fold!(noun, locality, PosTag::Position, dic: 5, flip: flip)
  end

  def fix_locality_val!(node : MtNode)
    case node.tag
    when .v_shang? then "trên"
    when .v_xia?   then "dưới"
    else                node.key == "中" ? "trong" : node.val
    end
  end
end
