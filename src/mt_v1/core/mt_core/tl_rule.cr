require "../sp_dict"
require "./tl_rule/**"

module M1::TlRule
  def fix_grammar!(node : MtNode) : Nil
    while node = node.succ?
      node = fold_once!(node)
      # puts [node, node.succ?, node.prev?].colorize.blue
    end
  end

  def fold_list!(head : MtNode, tail : MtNode? = nil) : Nil
    while head = head.succ?
      break if head == tail
      head = fold_once!(head)
    end
  end

  def fold_left!(right : MtNode, left : MtNode) : MtNode?
    case right
    when .suffixes?
      fold_suffix!(suff: right, left: left) if right.is_a?(MtDefn)
    when .postpos?
      return unless right.is_a?(MtList)

      fold_postpos!(postpos: right, left: left) || begin
        # reset postag if can not fold futher
        right.set!(right.list.first.tag)
        nil
      end
    else
      nil
    end
  end

  # ameba:disable Metrics/CyclomaticComplexity
  def fold_once!(node : MtNode) : MtNode
    # puts [node, node.succ?, node.prev?].colorize.red

    case node.tag
    when .polysemy?  then fold_mixed!(node)
    when .specials?  then fold_specials!(node)
    when .strings?   then fold_strings!(node)
    when .adverbial? then fold_adverbs!(node)
    when .preposes?  then fold_preposes!(node)
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
      # when .atsign?    then fold_atsign!(node)
    when .auxils? then fold_auxils!(node)
    else               node
    end
  end
end
