module CV::TlRule
  def fold_onoma!(node : String, succ = node.succ?) : MtNode
    return node unless succ

    case succ.tag
    when .ude1?
      succ.heal!("mà")
      break unless (succ_2 = succ.succ?) && succ_2.verbs?

      succ_2 = fold_verbs(succ_2)
      node = fold!(node, succ_2, succ_2.tag, 8)
    end

    node
  end

  private def heal_specials!(node : MtNode, succ = node.succ?) : MtNode
    case node.key
    when "完"
      node.val = "nộp"
      node.tag = PosTag::Verb
      return fold_verbs!(node)
    when "对不起"
      return node if boundary?(succ)
      fold_verbs!(node.heal!("có lỗi với", PosTag::Verb))
    when "百分之"
      return node unless succ && succ.numbers?
      succ = fold_number!(succ)
      node.fold!(succ, "#{succ.val} #{node.val}")
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
