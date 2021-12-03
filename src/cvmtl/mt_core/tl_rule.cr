require "./tl_rule/**"

module CV::TlRule
  def fix_grammar!(node : MtNode, level = 0) : Nil
    while node = node.succ?
      case node.tag
      when .popens?   then node = fold_quoted!(node)
      when .auxils?   then node = heal_auxils!(node)
      when .uniques?  then node = heal_uniques!(node)
      when .strings?  then node = fold_strings!(node)
      when .preposes? then node = fold_preposes!(node)
      when .pronouns? then node = fold_pronouns!(node)
      when .time?     then node = fold_time!(node)
      when .numeric?  then node = fold_number!(node)
      when .veno?     then node = fold_veno!(node)
      when .adverbs?  then node = fold_adverbs!(node)
      when .ajad?     then node = fold_ajad!(node)
      when .adjts?
        node = fold_adjts!(node, prev: nil)
        next unless node.nouns?
        node = fold_noun!(node)
        # node = fold_noun_left!(node, mode: mode)
      when .space?        then node = fold_space!(node)
      when .vmodals?      then node = heal_vmodal!(node)
      when .verbs?        then node = fold_verbs!(node)
      when .nouns?        then node = fold_noun!(node)
      when .onomatopoeia? then node = fold_onoma!(node)
      end
    end
  end
end
