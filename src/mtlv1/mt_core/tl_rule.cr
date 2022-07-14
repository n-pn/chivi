require "./mt_dict"
require "./tl_rule/**"

module CV::TlRule
  def fix_grammar!(node : MtNode, level = 0) : Nil
    # puts [node, node.idx, node.succ?, "level: #{level}"].colorize.blue

    while node = node.succ?
      node = fold_once!(node)
      # TODO: split fold methods to compound phrase and pattern phrase
    end
  end

  def fold_list!(head : MtNode, tail : MtNode? = nil) : Nil
    while head = head.succ?
      head = fold_once!(head)
      break if head == tail
    end
  end

  # ameba:disable Metrics/CyclomaticComplexity
  def fold_once!(node : MtNode) : MtNode
    case node.tag
    when .mixed?     then fold_mixed!(node)
    when .specials?  then fold_specials!(node)
    when .strings?   then fold_strings!(node)
    when .adverbial? then fold_adverbs!(node)
    when .preposes?  then fold_preposes!(node)
    when .auxils?    then heal_auxils!(node)
    when .pronouns?  then fold_pronouns!(node)
    when .ntime?     then fold_timeword!(node)
    when .numeral?   then fold_number!(node)
    when .modi?      then fold_modifier!(node)
    when .adjective? then fold_adjts!(node, prev: nil)
    when .vmodals?   then fold_vmodals!(node)
    when .verbal?    then fold_verbs!(node)
    when .locat?     then fold_space!(node)
    when .nominal?   then fold_nouns!(node)
    when .onomat?    then fold_onomat!(node)
    when .atsign?    then fold_atsign!(node)
    else                  node
    end
  end
end
