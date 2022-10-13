require "./fix_postag/**"
require "./join_nodes/**"

module MT::Core
  extend self

  def left_join!(tail : BaseNode, head : BaseNode) : Nil
    while tail = tail.prev?
      break if tail == head
      tail = join_word!(tail)
    end
  end

  def join_word!(node : BaseNode) : BaseNode
    if node.polysemy?
      node = fix_polysemy!(node.as(MonoNode))
    elsif node.uniqword?
      node = fix_uniqword!(node.as(MonoNode))
    end

    case node
    when .time_words? then join_time!(node)
    when .noun_words? then join_noun!(node)
    when .adjt_words? then join_adjt!(node)
    when .verb_words? then join_verb!(node)
    else                   node
    end
  end

  def join_group!(pstart : MonoNode, pclose : MonoNode) : Nil
    left_join!(pclose, pstart)
    tag, pos = guess_group_tag(pstart, pclose)
    SeriNode.new(pstart, pclose, tag: tag, pos: pos)
  end

  def guess_group_tag(head : BaseNode, tail : BaseNode) : {MtlTag, MtlPos}
    case head.tag
    when .title_sts? then MapTag::CapTitle
    when .brack_sts? then MapTag::CapOther
    when .paren_st1? then MapTag::ParenExp
    else                  guess_quote_group(head, tail)
    end
  end

  def guess_quote_group(head : BaseNode, tail : BaseNode) : {MtlTag, MtlPos}
    head_succ = head.succ
    tail_prev = tail.prev

    if head_succ == tail_prev
      return {head_succ.tag, head_succ.pos}
    end

    if (tail_prev.interj? || tail_prev.pt_dep?) &&
       (head_succ.onomat? || head_succ.interj?) &&
       (head.prev?(&.boundary?.!) || tail.succ?(&.pt_dep?))
      return {head_succ.tag, head_succ.pos}
    end

    head.prev?(&.pt_dep?) ? MapTag::Nform : MapTag::LitBlank
  end

  def fold!(head : BaseNode, tail : BaseNode,
            tag : {MtlTag, MtlPos}? = nil, flip : Bool = false)
    tag ||= {tail.tag, tail.pos}
    # FIXME: remove this helper and using proper structures
    SeriNode.new(head, tail, tag[0], tag[1], flip: flip)
  end
end
