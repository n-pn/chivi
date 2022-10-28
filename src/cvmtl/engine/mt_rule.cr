require "./mt_rule/**"

# require "./mt_util"

module MT::Core
  extend self

  def left_join!(tail : MtNode, head : MtNode) : Nil
    while tail = tail.prev?
      break if tail == head
      tail = fold_left!(tail)
    end
  end

  def fold_left!(node : MtNode) : MtNode
    node = fix_mixedpos!(node) if node.mixedpos?

    case node
    when .suffixes?     then fold_suffix!(node)
    when .time_words?   then fold_time!(node)
    when .noun_words?   then fold_noun!(node)
    when .adjt_words?   then join_adjt!(node)
    when .verbal_words? then fold_verb!(node)
    when .ptcl_dep?     then node.tap(&.as(MonoNode).skipover!)
    else                     node
    end
  end

  def join_group!(pstart : MonoNode, pclose : MonoNode) : Nil
    left_join!(pclose, pstart)
    tag, pos = guess_group_tag(pstart, pclose)
    SeriNode.new(pstart, pclose, tag: tag, pos: pos)
  end

  def guess_group_tag(head : MtNode, tail : MtNode) : {MtlTag, MtlPos}
    case head.tag
    when .title_sts? then PosTag.make(:title_name)
    when .brack_sts? then PosTag.make(:other_name)
    when .paren_st1? then PosTag.make(:paren_exp)
    else                  guess_quote_group(head, tail)
    end
  end

  def guess_quote_group(head : MtNode, tail : MtNode) : {MtlTag, MtlPos}
    head_succ = head.succ
    tail_prev = tail.prev

    if head_succ == tail_prev
      return {head_succ.tag, head_succ.pos}
    end

    if (tail_prev.interj? || tail_prev.ptcl_dep?) &&
       (head_succ.onomat? || head_succ.interj?) &&
       (head.prev?(&.boundary?.!) || tail.succ?(&.ptcl_dep?))
      return {head_succ.tag, head_succ.pos}
    end

    head.prev?(&.ptcl_dep?) ? PosTag.make(:nmix) : PosTag.make(:lit_blank)
  end

  def fold!(head : MtNode, tail : MtNode,
            tag : {MtlTag, MtlPos}? = nil, flip : Bool = false)
    tag ||= {tail.tag, tail.pos}
    # FIXME: remove this helper and using proper structures
    SeriNode.new(head, tail, tag[0], tag[1], flip: flip)
  end
end
