module CV::TlRule
  def fold_specials!(node : MtNode)
    case node
    when .adj_hao? then fix_adj_hao(node)
    when .v_shang? then fix_上下(node, MAP_上)
    when .v_xia?   then fix_上下(node, MAP_下)
    when .key_in?("和", "跟")
      if node.prev? { |x| x.ends? || x.adverb? } || concoord_is_prepos?(node.succ?)
        node.set!(PosTag::Prepos)
      else
        val = node.key == "和" ? "và" : node.val
        node.set!(val, PosTag::Concoord)
      end
    else
      fold_uniqs!(node)
    end
  end

  def concoord_is_prepos?(node : MtNode?)
    return false unless node

    while node = node.succ?
      if node.verbal?
        return !node.specials?
      elsif node.specials?
        return true if node.key_in?("上", "下") && fix_上下(node).verb?
      elsif node.puncts?
        return false unless node.penum?
      end
    end
  end

  MAP_上 = {"lên", "trên", "thượng"}
  MAP_下 = {"xuống", "dưới", "hạ"}

  def fix_上下(node : MtNode, vals = node.key == "上" ? MAP_上 : MAP_下) : MtNode
    case node.prev?
    when .nil?, .none?, .puncts?
      if node.succ? { |x| x.subject? || x.ule? }
        node.set!(vals[0], PosTag::Verb)
      else
        node.set!(vals[2], PosTag::Noun)
      end
    when .noun?, .naffil?
      node.set!(vals[1], PosTag::Locality)
    when .verb?, .vintr?
      node.set!(vals[0], PosTag::Vdir)
    else
      node
    end
  end

  def fix_adj_hao(node : MtNode) : MtNode
    case succ = node.succ?
    when .nil?, .puncts?, .ule?
      node.set!("tốt", PosTag::Adjt)
    when .adjective?, .verbal?, .vmodals?, .adverbial?
      node.set!(succ.verbal? ? "dễ" : "thật", PosTag::Adverb)
    when .nominal?
      node.set!("tốt", PosTag::Adjt)
    else
      node
    end
  end

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
