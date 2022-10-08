module CV::TlRule
  def join_adjt!(adjt : BaseNode) : BaseNode
    adjt = join_adjt_1!(adjt)
    adjt = join_adjt_2!(adjt)

    adjt
  end

  def join_adjt_1!(adjt : BaseNode) : BaseNode
    ptag = PosTag.new(:aform)
    adjt = join_adjt_0!(adjt)

    while (prev = adjt.prev?) && prev.adjt_words?
      prev = join_adjt_0!(prev)
      adjt = BasePair.new(prev, adjt, tag: ptag)
    end

    adjt
  end

  def join_adjt_0!(adjt : BaseNode)
    return adjt unless prev = adjt.prev?
    ptag = PosTag.new(:aform)

    while prev.adjt_words?
      adjt = BasePair.new(prev, adjt, tag: ptag, flip: false)
      prev = prev.prev
    end

    while prev.advb_words?
      adjt = BasePair.new(prev, adjt, tag: ptag, flip: prev.at_tail?)
      prev = prev.prev
    end

    adjt
  end

  def join_adjt_2!(adjt : BaseNode, prev : BaseNode = adjt.prev) : BaseNode
    case prev
    when .bw_bu4?
      BaseBond.new(bond: prev, head: prev.prev, tail: adjt, flip: true)
    when .bond_adjt?
      raise "prev.prev must be adjts!" unless prev.prev.tag.adjt_words?
      prev.prev = join_adjt_1!(prev.prev)
      BaseBond.new(bond: prev, head: prev.prev, tail: adjt, flip: false)
    when .bond_dmod?
      prev.prev = join_word!(prev.prev)
      BaseBond.new(bond: prev, head: prev.prev, tail: adjt, flip: false)
    else
      adjt
    end
  end
end
