module CV::TlRule
  private def fold_uniqs!(node : MtNode, succ = node.succ?) : MtNode
    # puts [node, succ, "fold_uniq"]

    case node.tag
    when .v_shi? then fold_v_shi!(node, succ)
    when .v_you?
      fold_compare_vyou!(node, succ)
    when .v_shang?, .v_xia?
      # puts [node, succ, "fold_noun_space"]
      fold_verbs!(node)
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
        fold_verbs!(MtDict.fix_verb!(node))
      end
    when "对不起"
      return node if boundary?(succ)
      fold_verbs!(MtDict.fix_verb!(node))
    when "原来"
      if succ.try(&.ude1?) || node.prev?(&.contws?)
        node.set!("ban đầu", tag: PosTag::Modi)
      else
        node.set!("thì ra")
      end
    when "行"
      succ.nil? || succ.ends? ? node.set!("được") : node
    else
      node
    end
  end
end
