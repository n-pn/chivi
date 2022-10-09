module MT::Core
  def join_time!(time : BaseNode)
    while prev = time.prev?
      return time unless prev.time_words?

      tag, pos = MapTag::Texpr
      time = BasePair.new(prev.swap_val!, time, tag, pos, flip: true)
    end

    time
  end
end
