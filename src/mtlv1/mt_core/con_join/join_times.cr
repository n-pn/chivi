module CV::TlRule
  def join_time!(time : BaseNode)
    while prev = time.prev?
      return time unless prev.time_words?
      time = BasePair.new(prev.swap_val!, time, tag: PosTag::Texpr, flip: true)
    end

    time
  end
end
