require "./tl_rule/**"

module CV::TlRule
  def fix_grammar!(node : MtNode, mode = 1, level = 0) : Nil
    while node = node.succ?
      # puts ["level: #{level}", node, node.succ?, node.body?]
      # gets

      case node.tag
      when .puncts?   then node = fold_puncts!(node, mode: mode)
      when .auxils?   then node = heal_auxils!(node, mode: mode)
      when .uniques?  then node = heal_uniques!(node)
      when .strings?  then node = fold_strings!(node)
      when .preposes? then node = fold_preposes!(node)
      when .pronouns? then node = fold_pronouns!(node)
      when .numeric?
        node = fold_number!(node)
        if node.nquants?
          next if (succ = node.succ?) && (succ.nouns? || succ.ude1?)
          node = fold_noun_left!(node, mode: mode)
        elsif node.nphrase?
          node = fold_noun_left!(node, mode: mode)
        elsif node.verbs?
          node = fold_verbs!(node)
        end
      when .veno?
        node = heal_veno!(node)
        if node.noun?
          node = fold_noun!(node)
          node = fold_noun_left!(node)
        else
          node = fold_verbs!(node)
        end
      when .adverbs?
        node = fold_adverbs!(node)
      when .ajad?
        node = fold_ajad!(node)
      when .adjts?
        node = fold_adjts!(node, prev: nil)
        next unless node.nouns?
        node = fold_noun!(node)
        node = fold_noun_left!(node, mode: mode)
      when .space?
        if prev = node.prev?
          node = fold_noun_space!(prev, node) if prev.nouns?
        end

        node = fold_noun_left!(node, mode: mode)
      when .vmodals? then node = heal_vmodal!(node)
      when .verbs?
        node = fold_verbs!(node)
      when .nform?, .nphrase?
        node = fold_noun_left!(node, mode: mode)
      when .nouns?
        node = fold_noun!(node)
        next unless node.nouns?
        node = fold_noun_left!(node, mode: mode)
      when .onomatopoeia? then node = fold_onoma!(node)
      end
    end
  end
end
