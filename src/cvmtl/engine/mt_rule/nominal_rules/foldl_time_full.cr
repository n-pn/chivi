require "./*"

module MT::Rules
  def foldl_time_full!(time : MtNode)
    tag, pos = PosTag.make(:timeword)

    while (prev = time.prev?) && prev.all_times?
      prev.fix_val! if prev.is_a?(MonoNode)
      time = PairNode.new(prev, time, tag, pos, flip: true)
    end

    return foldl_noun_expr!(time) if time.prev.ptcl_dep?

    # FIXME: handle time as verb complement
    time.succ.verbal_words? ? time : foldl_objt_full!(objt: time)
  end
end
