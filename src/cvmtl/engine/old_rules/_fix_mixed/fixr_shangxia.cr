module MT::Rules
  extend self

  def fixr_shangxia!(head : MonoNode, succ = head.succ, prev = head.prev)
    case succ
    when .all_times?
      head.tap { |x| x.pos |= :maybe_modi }
    when .aspect_marker?
      return head if prev.all_nouns?

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
