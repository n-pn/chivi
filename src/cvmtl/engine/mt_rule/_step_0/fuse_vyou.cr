module MT::Core::Step0
  def fuse_vyou!(vyou : MonoNode, succ : MonoNode)
    case succ
    when .nabst?, .nattr?
      tag, pos = PosTag.make(:amix)
      PairNode.new(vyou, succ, tag, pos)
    when .key?("些", "点")
      tail = succ.succ
      # FIXME: as more case here
      return vyou unless tail.adjt_words?
      tag, pos = PosTag.make(:amix)

      TrioNode.new(vyou, succ, tail, tag, pos)
    else
      vyou
    end
  end
end
