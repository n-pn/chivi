module CV::TlRule
  def fold_onoma!(node : MtNode, succ = node.succ?) : MtNode
    return node unless succ

    case succ.tag
    when .ude1?
      succ.set!("mà")
      return node unless (succ_2 = succ.succ?) && succ_2.verbs?

      succ_2 = fold_verbs!(succ_2)
      fold!(node, succ_2, succ_2.tag, dic: 8)
    else
      node
    end
  end

  private def heal_uniques!(node : MtNode, succ = node.succ?) : MtNode
    # puts [node, succ, "heal_uniq"]

    case node.tag
    when .v_shi?
      fold_v_shi!(node, succ)
    when .v_you?
      # TODO handle vyou
      return node
    when .v_shang?, .v_xia?
      # puts [node, succ, "fold_noun_space"]

      return node unless succ && (succ.ule?)
      fold_verbs!(node)
    when .adj_hao?
      return node unless succ

      case succ
      when .ule?, .nouns?
        node.tag == PosTag::Adjt
        fold_adjts!(node)
      when .adjts?, .verbs?, .vmodals?
        node.set!(succ.adjts? ? "thật" : "dễ", PosTag::Adverb)
        fold_adverbs!(node, succ)
      else
        node
      end
    else
      heal_uniques_by_key!(node, succ)
    end
  end

  def heal_uniques_by_key!(node : MtNode, succ = node.succ?)
    case node.key
    when "第" then fold_第!(node)
    when "完"
      if node.succ?(&.puncts?)
        node.set!("hết")
      else
        node.val = "nộp"
        node.tag = PosTag::Verb
        fold_verbs!(node)
      end
    when "对不起"
      return node if boundary?(succ)
      fold_verbs!(node.set!("có lỗi với", PosTag::Verb))
    when "百分之"
      return node unless succ && succ.numbers?
      succ = fuse_number!(succ)
      fold!(node, succ, PosTag::Number, dic: 4, flip: true)
    when "原来"
      if succ.try(&.ude1?) || node.prev?(&.contws?)
        node.set!("ban đầu", tag: PosTag::Modifier)
      else
        node.set!("thì ra")
      end
    when "行"
      return node if succ.nil? || succ.titlecl?
      boundary?(succ) ? node.set!("được") : node
    when "高达"
      if succ.try(&.numeric?)
        node.set!("cao đến")
      else
        node.set!("Gundam", tag: PosTag::Noun)
      end
    else
      node
    end
  end
end
