module CV::TlRule
  def join_time!(time : BaseNode, prev = time.prev)
    loop do
      return time unless prev.timeword?
      time = pair!(prev.swap_val!, time, flip: true)
      prev = time.prev
    end

    time
  end
end
