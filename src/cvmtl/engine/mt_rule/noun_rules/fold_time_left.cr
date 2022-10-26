require "./*"

module MT::Core
  def fold_time!(time : MtNode)
    tag, pos = PosTag.make(:timeword)

    while (prev = time.prev?) && prev.time_words?
      prev.fix_val! if prev.is_a?(MonoNode)
      time = PairNode.new(prev, time, tag, pos, flip: true)
    end

    return cons_noun!(time) if time.prev.ptcl_dep?

    # FIXME: handle time as verb complement
    time.succ.verbal_words? ? time : fold_objt_left!(objt: time)
  end
end
