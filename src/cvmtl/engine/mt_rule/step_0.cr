require "./left_to_right/**"

module MT::Rules::LTR
  extend self

  def run!(head : MtNode, tail : MtNode) : Nil
    while (head = head.succ?) && head.is_a?(MonoNode)
      head = fixr_mixedpos!(head) if head.mixedpos?

      case head
      when .numbers?      then head = foldr_number_base!(head)
      when .adjt_words?   then head = foldr_adjt_base!(head)
      when .verbal_words? then head = foldr_verb_base!(head)
      when .maybe_cmpl?   then head = fixr_not_cmpl!(head)
      when .maybe_quanti? then head = as_not_quanti!(head)
      end
    end
  end

  def fixr_not_cmpl!(head : MonoNode)
    case head
    when .loc_zhong?
      head.tap(&.pos = head.pos & ~MtlPos::MaybeCmpl)
    when .loc_shang?, .loc_xia?
      fixr_shangxia!(head)
    else
      head.tag, head.pos = PosTag.not_vcompl(head.key)
      head
    end
  end

  def fixr_shangxia!(head : MonoNode, succ = head.succ, prev = head.prev)
    case succ
    when .time_words?
      head.tap { |x| x.pos |= :maybe_modi }
    when .aspect_marker?
      return head if prev.noun_words?

      if head.loc_shang?
        head.val = "lên"
        head.tag, head.pos = PosTag.make(:v_shang)
      else
        head.val = "xuống"
        head.tag, head.pos = PosTag.make(:v_xia)
      end

      head
    else
      head
    end
  end
end
