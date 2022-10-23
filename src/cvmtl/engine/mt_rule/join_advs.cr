module MT::Core
  def join_advb!(advb : MtNode)
    while prev = advb.prev?
      return advb unless prev.advb_words?

      ptag = PosTag.make(:adv_form)
      advb = PairNode.new(prev.fix_val!, advb, tag: ptag, flip: true)
    end

    advb
  end
end
