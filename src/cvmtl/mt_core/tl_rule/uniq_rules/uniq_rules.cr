module CV::TlRule
  private def fold_uniqs!(node : MtNode, succ = node.succ?) : MtNode
    # puts [node, succ, "fold_uniq"]

    case node.tag
    when .v_shi?
      fold_v_shi!(node, succ)
    when .v_you?
      fold_compare_vyou!(node, succ)
    when .v_shang?, .v_xia?
      # puts [node, succ, "fold_noun_space"]
      fold_verbs!(node)
    when .adj_hao?
      return node unless succ

      case succ
      when .ule?, .nouns?
        node.tag == PosTag::Adjt
        fold_adjts!(node)
      when .adjts?, .verbs?, .vmodals?
        node.set!(succ.verbs? ? "dễ" : "thật", PosTag::Adverb)
        fold_adverbs!(node, succ)
      else
        node
      end
    else
      fold_uniqs_by_key!(node, succ)
    end
  end

  # ameba:disable Metrics/CyclomaticComplexity
  def fold_uniqs_by_key!(node : MtNode, succ = node.succ?)
    case node.key
    when "第" then fold_第!(node)
    when "完"
      case node.succ?
      when .nil?, .ends?, .ule?
        node.set!("hết")
      else
        # node.val = "nộp"
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
