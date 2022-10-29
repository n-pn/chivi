require "./*"

module MT::Rules
  def foldl_time_full!(time : MtNode)
    tag, pos = PosTag.make(:timeword)

    while (prev = time.prev?) && prev.time_words?
      prev.fix_val! if prev.is_a?(MonoNode)
      time = PairNode.new(prev, time, tag, pos, flip: true)
    end

    return foldl_noun_form!(time) if time.prev.ptcl_dep?

    # FIXME: handle time as verb complement
    time.succ.verbal_words? ? time : foldl_objt_full!(objt: time)
  end
end
