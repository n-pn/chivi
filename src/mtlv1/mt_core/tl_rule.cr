require "./tl_rule/**"

module CV::TlRule
  def fold_left!(tail : BaseNode)
    while tail
      break unless prev = tail.prev?
      tail = fold_left!(tail, prev).try(&.prev?) || tail.prev?
    end
  end

  def fold_left!(right : BaseNode, left : BaseNode) : BaseNode
    case right
    when .timeword? then join_time!(right, left)
    when .nominal?  then fold_noun_left!(right, level: 0)
    when .suffixes?
      fold_suffix!(suff: right, left: left)
    else
      right
    end
  end

  def fix_grammar!(node : BaseNode) : Nil
    while node = node.succ?
      node = fold_once!(node)
      # puts [node, node.succ?, node.prev?].colorize.blue
    end
  end

  def fold_list!(head : BaseNode, tail : BaseNode? = nil) : Nil
    while head = head.succ?
      break if head == tail
      head = fold_once!(head)
    end
  end

  # ameba:disable Metrics/CyclomaticComplexity
  def fold_once!(node : BaseNode) : BaseNode
    # puts [node, node.succ?, node.prev?].colorize.red

    case node.tag
    # when .polysemy?  then fold_mixed!(node)
    # when .uniqword?  then fold_specials!(node)
    when .advbial?  then fold_adverbs!(node)
    when .preposes? then fold_preposes!(node)
    when .pronouns? then fold_pronouns!(node)
    when .timeword? then fold_timeword!(node)
    when .numeral?  then fold_number!(node)
    when .modis?    then fold_modis?(node)
    when .adjts?    then fold_adjts!(node, prev: nil)
    when .vmodals?  then fold_vmodal!(node)
    when .verbal?   then fold_verbs!(node)
      # when .locat?     then fold_space!(node)
    when .nominal?   then fold_nouns!(node)
    when .onomat?    then fold_onomat!(node)
    when .atsign?    then fold_atsign!(node)
    when .particles? then fold_auxils!(node)
    else                  node
    end
  end

  def pair!(left : BaseNode, right : BaseNode, ptag = right.tag, dic = 0, flip = left.at_tail? || right.at_head?)
    BasePair.new(left, right, ptag, dic: dic, idx: left.idx, flip: flip)
  end
end
