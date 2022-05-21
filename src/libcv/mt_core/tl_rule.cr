require "./mt_dict"
require "./tl_rule/**"

module CV::TlRule
  def fix_grammar!(node : MtNode, level = 0) : Nil
    # puts [node, node.idx, node.succ?, "level: #{level}"].colorize.blue

    while node = node.succ?
      node = fold_once!(node)
    end
  end

  # ameba:disable Metrics/CyclomaticComplexity
  def fold_once!(node : MtNode) : MtNode
    case node.tag
    when .puncts?    then fold_puncts!(node)
    when .strings?   then fold_strings!(node)
    when .mixed?     then fold_mixed!(node)
    when .adverbial? then fold_adverbs!(node)
    when .preposes?  then fold_preposess!(node)
    when .specials?  then fold_specials!(node)
    when .auxils?    then heal_auxils!(node)
      # when .specials?  then fold_uniqs!(node)
    when .strings?   then fold_strings!(node)
    when .preposes?  then fold_preposes!(node)
    when .pronouns?  then fold_pronouns!(node)
    when .timeword?  then fold_timeword!(node)
    when .numeral?   then fold_number!(node)
    when .veno?      then fold_veno!(node)
    when .ajad?      then fold_ajad!(node)
    when .adverbial? then fold_adverbs!(node)
    when .modi?      then fold_modifier!(node)
    when .ajno?      then fold_ajno!(node)
    when .adjective? then fold_adjts!(node, prev: nil)
    when .locality?  then fold_space!(node)
    when .vmodals?   then fold_vmodals!(node)
    when .verbal?    then fold_verbs!(node)
    when .nominal?   then fold_nouns!(node)
    when .onomat?    then fold_onomat!(node)
    else                  node
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
end
