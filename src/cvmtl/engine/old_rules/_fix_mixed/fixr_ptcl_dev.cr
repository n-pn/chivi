module MT::Rules
  def fixr_ptcl_dev!(udev : MonoNode, succ = udev.succ, prev = udev.prev)
    if succ.is_a?(MonoNode) && succ.mixedpos?
      succ = fixr_mixedpos!(succ, prev: udev)
    end

    case
    when succ.all_nouns?, prev.preposes?, succ.boundary?, prev.boundary?
      udev_as_noun!(udev)
    else
      udev
    end
  end

  def udev_as_noun!(udev : MonoNode)
    udev.val = "đất"
    udev.tag, udev.pos = PosTag.make(:place)
    udev
  end
end
