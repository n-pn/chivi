module MT::Core
  def join_time!(time : MtNode)
    while prev = time.prev?
      return time unless prev.time_words?

      tag, pos = PosTag::Texpr
      time = PairNode.new(prev.swap_val!, time, tag, pos, flip: true)
    end

    time
  end
end
