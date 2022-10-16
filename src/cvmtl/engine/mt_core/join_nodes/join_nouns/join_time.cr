require "./*"

module MT::Core
  def join_time!(time : MtNode)
    while prev = time.prev?
      case prev
      when .time_words?
        tag, pos = PosTag::Texpr
        time = PairNode.new(prev.swap_val!, time, tag, pos, flip: true)
      when .preposes?
        return make_prep_form!(noun: time, prep: prev.as(MonoNode))
      else
        return time
      end
    end

    time
  end
end
