# require "./mt_util"
require "./mt_rule/**"

module MT::Rules
  extend self

  def foldr_all!(head : MtNode, tail : MtNode) : Nil
    while (head = head.succ?) && head != tail
      next unless head.is_a?(MonoNode)
      head = foldr_once!(head)
    end
  end

  def foldr_once!(node : MonoNode)
    node = fixr_mixedpos!(node) if node.mixedpos?

    case node
    when .numbers?      then foldr_number_base!(node)
    when .adjt_words?   then foldr_adjt_base!(node)
    when .verbal_words? then foldr_verb_base!(node)
    when .name_words?   then foldr_name_base!(node)
    when .maybe_cmpl?   then fixr_not_cmpl!(node)
      # when .maybe_quanti? then as_not_quanti!(node)
    else node
    end
  end

  def foldl_all!(tail : MtNode, head : MtNode) : Nil
    while tail = tail.prev?
      break if tail == head
      tail = foldl_once!(tail)
    end
  end

  def foldl_once!(node : MtNode) : MtNode
    node = fix_mixedpos!(node) if node.mixedpos?

    case node
    when .suffixes?     then foldl_suffix_full!(node)
    when .all_times?    then foldl_time_full!(node)
    when .all_nouns?    then foldl_noun_full!(node)
    when .adjt_words?   then foldl_adjt_full!(node)
    when .verbal_words? then foldl_verb_full!(node)
    when .ptcl_dep?     then node.tap(&.as(MonoNode).skipover!)
    else                     node
    end
  end

  def join_group!(pstart : MonoNode, pclose : MonoNode) : Nil
    foldl_all!(pclose, pstart)
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
end
