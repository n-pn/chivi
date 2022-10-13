module MT::Core
  def join_advb!(advb : BaseNode)
    while prev = advb.prev?
      return advb unless prev.advb_words?

      ptag = MapTag.make(:adv_form)
      advb = PairNode.new(prev.swap_val!, advb, tag: ptag, flip: true)
    end

    advb
  end
end
