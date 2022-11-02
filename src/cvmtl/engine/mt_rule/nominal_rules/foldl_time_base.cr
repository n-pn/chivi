require "./*"

module MT::Rules
  def foldl_time_base!(time : MtNode)
    tag, pos = PosTag.make(:timeword)

    while (prev = time.prev) && prev.all_times?
      prev.fix_val! if prev.is_a?(MonoNode)
      time = PairNode.new(prev, time, tag, pos, flip: true)
    end

    time
  end
end
