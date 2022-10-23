require "./*"

module MT::Core
  def fold_time!(time : MtNode)
    tag, pos = PosTag::Texpr

    while (prev = time.prev?) && prev.time_words?
      prev.swap_val! if prev.is_a?(MonoNode)
      time = PairNode.new(prev, time, tag, pos, flip: true)
    end

    # FIXME: handle time as verb complement
    time.succ.verb_words? ? time : fold_objt_left!(objt: time)
  end
end
