module CV::MtlV2::TlRule
  LOCALITY_VERBS = {
    "中" => "trúng",
    "上" => "lên",
    "下" => "xuống",
  }

  def fold_space!(node : MtNode) : MtNode
    case node.key
    when "上", "下", "中"
      case succ = node.succ?
      when .nil?, .pstops?, .none? then node
      when .exclam?, .mopart?, .auxils?, .quantis?
        node.set!(LOCALITY_VERBS[node.key], PosTag::Verb)
      else
        fold_nouns!(succ)
      end
    when "右", "左"
      fold_modifier!(node.set!(PosTag::Modi))
    else
      fold_nouns!(node)
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
