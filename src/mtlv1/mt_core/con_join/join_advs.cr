module CV::TlRule
  def join_advb!(advb : BaseNode)
    while prev = advb.prev?
      return advb unless prev.advb_words?

      ptag = PosTag.new(:adv_form)
      advb = BasePair.new(prev.swap_val!, advb, tag: ptag, flip: true)
    end

    advb
  end
end