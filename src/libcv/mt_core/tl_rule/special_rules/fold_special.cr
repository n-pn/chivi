module CV::TlRule
  def fold_specials!(node : MtNode, succ = node.succ?)
    return node.flag!(:resolved) unless succ

    case node
    when .verbal?    then fold_special_verbs!(node, succ)
    when .adjective? then fold_special_adjt!(node, succ)
    when .key_in?("和", "跟")
      if node.prev? { |x| x.ends? || x.adverb? } || concoord_is_prepos?(node.succ?)
        node.set!(PosTag::Prepos)
      else
        val = node.key == "和" ? "và" : node.val
        node.set!(val, PosTag::Concoord)
      end
    else
      fold_uniqs_by_key!(node)
    end
  end

  def fold_special_verbs!(node : MtNode, succ : MtNode)
    case node
    when .v_shi? then fold_v_shi!(node, succ)
    when .v_you? then fold_v_you!(node, succ)
    when .locality?
      node.val = node.key == '上' ? "lên" : "xuống"
      fold_verbs!(node)
    when .v_compare?
      fold_compare(node, succ) || fold_verbs!(node)
    when .v_combine?
      return fold_verbs!(node) unless succ.verbal?
      succ = fold_verbs!(succ)

      node.val = MtDict.v_combine.get_val(node.key) || node.val

      node = fold!(node, succ, succ.tag, dic: 5)
      node.flag!(:checked)
    else
      fold_verbs!(node)
    end
  end

  def fold_special_adjt!(node : MtNode, succ : MtNode)
    case node
    when .adj_hao? then fold_adj_hao!(node, succ)
    when .measure? then fold_adjt_number!(node, succ)
    else                fold_adjts!(node)
    end
  end

  def concoord_is_prepos?(node : MtNode?)
    return false unless node

    while node = node.succ?
      if node.verbal?
        return !node.special?
      elsif node.special?
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
      node.set!(vals[0], PosTag::VDircomp)
    else
      node
    end
  end

  def fold_adj_hao!(node : MtNode, succ : MtNode) : MtNode
    case succ
    when .puncts?, .ule?
      node.set!("tốt", PosTag::Adjt)
    when .adjective?, .verbal?, .vmodals?, .adverbial?
      node.set!(succ.verbal? ? "dễ" : "thật", PosTag::Adverb)
      fold_adverb_base!(node)
    when .nominal?
      node.set!("tốt", PosTag::Adjt)
      fold_nouns!(noun: succ, modi: node)
    else
      node
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
      if node.prev? { |x| x.puncts? || x.none? }
        node.set!("thì ra", PosTag::Conjunct)
      else
        node.set!("ban đầu", tag: PosTag::Modi)
        fold_modifier!(node)
      end
    when "行"
      case succ
      when .nil?, .pstop?
        node.set!("hành")
      when .ends?, .puncts?
        node.set!("được")
      else
        fold_verbs!(node.set!(PosTag::Verb))
      end
    else
      node
    end
  end
end
