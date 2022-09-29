module CV::TlRule
  def fold_time_left!(time : MtNode) : MtNode
    while prev = time.prev?
      break unless prev.ntime?
      time = fold!(prev, time, time.tag, flip: true)
    end

    time
  end
end
