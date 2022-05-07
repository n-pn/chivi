require "./mt_dict"
require "./tl_rule/**"

module CV::TlRule
  # ameba:disable Metrics/CyclomaticComplexity
  def fix_grammar!(node : MtNode, level = 0) : Nil
    preprocess!(node)

    # puts [node, node.idx, node.succ?, "level: #{level}"].colorize.blue

    while node = node.succ?
      case node.tag
      when .auxils?   then node = heal_auxils!(node)
      when .specials? then node = fold_uniqs!(node)
      when .strings?  then node = fold_strings!(node)
      when .preposes? then node = fold_preposes!(node)
      when .pronouns? then node = fold_pronouns!(node)
      when .time?     then node = fold_time!(node)
      when .numeric?  then node = fold_number!(node)
      when .veno?     then node = fold_veno!(node)
      when .ajad?     then node = fold_ajad!(node)
      when .adverbs?  then node = fold_adverbs!(node)
      when .modifier? then node = fold_modifier!(node)
      when .ajno?     then node = fold_ajno!(node)
      when .adjts?    then node = fold_adjts!(node, prev: nil)
      when .space?    then node = fold_space!(node)
      when .vmodals?  then node = fold_vmodals!(node)
      when .verbs?    then node = fold_verbs!(node)
      when .nouns?    then node = fold_nouns!(node)
      when .onomat?   then node = fold_onomat!(node)
      end
    end
  end

  def preprocess!(node : MtNode)
    while node = node.succ?
      case node.tag
      when .titleop?  then node = fold_ptitle!(node)
      when .popens?   then node = fold_quoted!(node)
      when .atsign?   then node = fold_atsign!(node)
      when .specials? then node = pre_special!(node)
      when .veno?     then node = heal_veno!(node)
      when .ajno?     then node = heal_ajno!(node)
      end
    end
  end

  def pre_special!(node : MtNode)
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
      node
    end
  end

  def concoord_is_prepos?(node : MtNode?)
    return false unless node

    while node = node.succ?
      if node.verbs?
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
      node.set!(vals[1], PosTag::Space)
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
    when .adjts?, .verbs?, .vmodals?, .adverbs?
      node.set!(succ.verbs? ? "dễ" : "thật", PosTag::Adverb)
    when .nouns?
      node.set!("tốt", PosTag::Adjt)
    else
      node
    end
  end
end
