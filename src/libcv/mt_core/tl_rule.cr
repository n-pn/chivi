require "./mt_dict"
require "./tl_rule/**"

module CV::TlRule
  def fix_grammar!(node : MtNode, level = 0) : Nil
    # puts [node, node.idx, node.succ?, "level: #{level}"].colorize.blue

    while node = node.succ?
      node = fold_once!(node)
    end
  end

  def fold_once!(node : MtNode)
    return node if node.flag.resolved?
    # puts [node, node.flag]
    node = fuse_once!(node) unless node.flag.checked?

    case node
    when .nominal?  then fold_nouns!(node)
    when .special?  then node # should triggered by fuse_once!
    when .verbal?   then fold_verbs!(node)
    when .preposes? then fold_preposes!(node)
      # when .numeral? then scan_noun!(node.succ?, nquant: node) || node
    else node.flag!(:checked)
    end
  end

  # ameba:disable Metrics/CyclomaticComplexity
  def fuse_once!(node : MtNode) : MtNode
    # puts [node, node.flag]

    case node.tag
    when .mixed?     then meld_mixed!(node)
    when .special?   then fold_specials!(node)
    when .puncts?    then fold_puncts!(node)
    when .strings?   then fold_strings!(node)
    when .adverbial? then fold_adverbs!(node)
    when .auxils?    then heal_auxils!(node)
    when .pronouns?  then fold_pronouns!(node)
    when .temporal?  then fold_timeword!(node)
    when .numeral?   then fold_number!(node)
    when .modi?      then fold_modifier!(node)
    when .adjective? then fold_adjts!(node, prev: nil)
    when .vmodals?   then fold_vmodals!(node)
    when .verbal?    then fuse_verb!(node)
    when .nominal?   then fuse_noun!(node)
    when .locality?  then fold_space!(node)
    when .onomat?    then fold_onomat!(node)
    else                  node
    end
  end
end
