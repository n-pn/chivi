require "./mt_dict"
require "./tl_rule/**"

module CV::TlRule
  # ameba:disable Metrics/CyclomaticComplexity
  def fix_grammar!(node : MtNode, level = 0) : Nil
    # puts [node, node.idx, node.succ?, "level: #{level}"].colorize.blue

    while node = node.succ?
      case node.tag
      when .popens?   then node = fold_nested!(node)
      when .auxils?   then node = heal_auxils!(node)
      when .uniques?  then node = fold_uniqs!(node)
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
      when .concoord?
        next unless node.key.in?("与", "和")
        fold_compare(node).try { |x| node = x; next }
        node = fold_prepos_inner!(node)
      end
    end
  end
end
