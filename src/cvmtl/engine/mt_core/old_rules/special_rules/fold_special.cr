module MT::TlRule
  def fold_specials!(node : BaseNode)
    case node
    when .wd_hao?  then fold_wd_hao!(node)
    when .v_shang? then fix_上下(node, MAP_上)
    when .v_xia?   then fix_上下(node, MAP_下)
    when .key_in?("和", "跟")
      if node.prev? { |x| x.boundary? || x.advb_words? } || concoord_is_prepos?(node.succ?)
        fold_preposes!(node)
      else
        val = node.key == "和" ? "và" : node.val
        node.set!(val, MapTag::Concoord)
      end
    else
      fold_uniqs!(node)
    end
  end

  def concoord_is_prepos?(node : BaseNode?)
    return false unless node

    while node = node.succ?
      if node.verb_words?
        return !node.uniqword?
      elsif node.uniqword?
        return true if node.key_in?("上", "下") && fix_上下(node).verb?
      elsif node.punctuations?
        return false unless node.cenum?
      end
    end
  end

  MAP_上 = {"lên", "trên", "thượng"}
  MAP_下 = {"xuống", "dưới", "hạ"}

  def fix_上下(node : BaseNode, vals = node.key == "上" ? MAP_上 : MAP_下) : BaseNode
    case node.prev?
    when .nil?, .empty?, .punctuations?
      if node.succ? { |x| x.content? || x.pt_le? }
        node.set!(vals[0], MapTag::Verb)
      else
        node.set!(vals[2], MapTag::Noun)
      end
    when .common_nouns?
      node.set!(vals[1], MapTag::Locat)
    when .common_verbs?
      node.set!(vals[0], MapTag::Vdir)
    else
      node
    end
  end

  def fold_wd_hao!(node : BaseNode) : BaseNode
    case succ = node.succ?
    when .nil?, .punctuations?, .pt_le?
      node.set!("tốt", MapTag::Adjt)
    when .adjt_words?, .verb_words?, .modal_verbs?, .advb_words?
      node.set!(succ.verb_words? ? "dễ" : "thật", MapTag::Adverb)
      fold_adverb_base!(node, succ)
    when .noun_words?
      node.set!("tốt", MapTag::Adjt)
      fold_adjt_noun!(node, succ)
    else
      node
    end
  end

  private def fold_uniqs!(node : BaseNode, succ = node.succ?) : BaseNode
    # puts [node, succ, "fold_uniq"]

    case node.tag
    when .v_shi? then fold_v_shi!(node, succ)
    when .v_you? then succ ? fold_vyou!(node, succ) : node
    when .v_shang?, .v_xia?
      # puts [node, succ, "fold_noun_space"]
      fold_verbs!(node)
    else
      fold_uniqs_by_key!(node, succ)
    end
  end

  def fold_uniqs_by_key!(node : BaseNode, succ = node.succ?)
    case node.key
    when "第" then fold_第!(node)
    when "对不起"
      return node if boundary?(succ)
      fold_verbs!(node.set!("có lỗi với"))
    when "原来"
      case node.prev?
      when .nil?, .boundary?, .punctuations?
        node.set!("thì ra", MapTag::Conjunct)
      else
        node.set!("ban đầu", tag: MapTag::Modi)
      end
    when "行"
      succ.nil? || succ.boundary? ? node.set!("được") : node
    else
      node
    end
  end
end
