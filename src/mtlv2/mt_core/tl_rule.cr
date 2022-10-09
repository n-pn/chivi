# require "./tl_rule/**"
require "./con_join/**"

module MT::Core
  extend self

  def left_join!(tail : BaseNode, head : BaseNode) : Nil
    while tail = tail.prev?
      break if tail == head
      tail = join_word!(tail)
    end
  end

  def join_word!(node : BaseNode) : BaseNode
    case node
    when .time_words? then join_time!(node)
    when .noun_words? then join_noun!(node)
    when .adjt_words? then join_adjt!(node)
    when .verb_words? then join_verb!(node)
    else                   node
    end
  end

  def join_group!(pstart : BaseTerm, pclose : BaseTerm) : Nil
    left_join!(pclose, pstart)
    ptag = guess_group_tag(pstart, pclose)
    BaseSeri.new(pstart, pclose, tag: ptag)
  end

  def guess_group_tag(head : BaseNode, tail : BaseNode)
    case head.tag
    when .title_sts? then MapTag::CapTitle
    when .brack_sts? then MapTag::CapOther
    when .paren_st1? then MapTag::ParenExp
    else                  guess_quote_group(head, tail)
    end
  end

  def guess_quote_group(head : BaseNode, tail : BaseNode)
    head_succ = head.succ
    tail_prev = tail.prev

    return head_succ.tag if head_succ == tail_prev

    if (tail_prev.interj? || tail_prev.pt_dep?) &&
       (head_succ.onomat? || head_succ.interj?) &&
       (head.prev?(&.boundary?.!) || tail.succ?(&.pt_dep?))
      return head_succ.tag
    end

    head.prev?(&.pt_dep?) ? MapTag::Nform : MapTag::LitBlank
  end

  def fold!(head : BaseNode, tail : BaseNode,
            tag : {MtlTag, MtlPos} = MapTag::LitBlank, dic : Int32 = 9,
            flip : Bool = false)
    # FIXME: remove this helper and using proper structures

    BaseSeri.new(head, tail, tag[0], tag[1], flip: flip)
  end
end
