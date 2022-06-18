require "../mt_dict"
require "./tl_rule/**"

module MtlV2::TlRule
  def fix_grammar!(node : BaseNode) : Nil
    # puts [node, node.idx, node.succ?, "level: #{level}"].colorize.blue

    while node = node.succ?
      # puts [node, node.prev?]
      node = fold_once!(node)
    end
  end

  # ameba:disable Metrics/CyclomaticComplexity
  def fold_once!(node : BaseNode)
    case node.tag
    when .puncts?    then fold_puncts!(node)
    when .mixed?     then fold_mixed!(node)
    when .special?   then fold_specials!(node)
    when .preposes?  then fold_preposes!(node)
    when .strings?   then fold_strings!(node)
    when .adverbial? then fold_adverbs!(node)
    when .auxils?    then fold_auxils!(node)
    when .pronouns?  then fold_pronouns!(node)
    when .temporal?  then fold_temporal!(node)
    when .numeral?   then fold_number!(node)
    when .modifier?  then fold_modifier!(node)
    when .adjective? then fold_adjts!(node)
    when .vmodals?   then fold_vmodals!(node)
    when .verbal?    then fold_verbs!(node)
    when .locative?  then fold_space!(node)
    when .nominal?   then fold_nouns!(node)
    when .onomat?    then fold_onomat!(node)
    else                  node
    end
  end
end