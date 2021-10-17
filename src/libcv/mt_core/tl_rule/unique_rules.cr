module CV::TlRule
  def fold_onoma!(node : MtNode, succ = node.succ?) : MtNode
    return node unless succ

    case succ.tag
    when .ude1?
      succ.heal!("mà")
      return node unless (succ_2 = succ.succ?) && succ_2.verbs?

      succ_2 = fold_verbs!(succ_2)
      fold!(node, succ_2, succ_2.tag, dic: 8)
    else
      node
    end
  end

  private def heal_uniques!(node : MtNode, succ = node.succ?) : MtNode
    case node.tag
    when .v_shi?
      # TODO handle vshi
      return node
    when .v_you?
      # TODO handle vyou
      return node
    when .v_shang?, .v_xia?
      if succ
        case succ.tag
        when .ule? then return fold_verbs!(node)
        end
      end

      if node.prev.nouns?
        return fold_noun_space!(node.prev, node)
      else
        return fold_verbs!(node)
      end
    else
      heal_uniques_by_key!(node, succ)
    end
  end

  def heal_uniques_by_key!(node : MtNode, succ = node.succ?)
    case node.key
    when "完"
      node.val = "nộp"
      node.tag = PosTag::Verb
      return fold_verbs!(node)
    when "好"
      return node unless succ

      case succ
      when .verbs?, .adjts?
        node.val = "thật"
        node.tag == PosTag::Adverb
        fold_adverbs!(node, succ)
      else
        node
      end
    when "对不起"
      return node if boundary?(succ)
      fold_verbs!(node.heal!("có lỗi với", PosTag::Verb))
    when "百分之"
      return node unless succ && succ.numbers?
      succ = fold_number!(succ)
      fold_swap!(node, succ, PosTag::Number, dic: 4)
    when "原来"
      if succ.try(&.ude1?) || node.prev?(&.contws?)
        node.heal!("ban đầu", tag: PosTag::Modifier)
      else
        node.heal!("thì ra")
      end
    when "行"
      boundary?(succ) ? node.heal!("được") : node
    when "高达"
      if succ.try(&.nquants?)
        node.heal!("cao đến")
      else
        node.heal!("Gundam", tag: PosTag::Noun)
      end
    else
      node
    end
  end
end
