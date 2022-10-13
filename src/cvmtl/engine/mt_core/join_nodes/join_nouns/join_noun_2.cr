module MT::Core
  def join_noun_2!(noun : BaseNode, prev = noun.prev) : BaseNode
    if prev.adjt_words?
      noun = PairNode.new(prev, noun, flip: !prev.at_head?)
      prev = noun.prev
    end

    if prev.pt_deps?
      prev = join_udep!(prev)
      noun = PairNode.new(prev, noun, noun.tag, flip: true)
      prev = noun.prev
    end

    if prev.quantis? || prev.nquants?
      prev.as(MonoNode).inactivate! if prev.tag.qt_ge4?
      noun = PairNode.new(prev, noun, flip: false)
      prev = noun.prev
    end

    if prev.numbers?
      noun = PairNode.new(prev, noun, flip: prev.ordinal?)
      return noun unless prev = noun.prev?
    end

    if prev.pro_dems? || prev.pro_na2?
      noun = PairNode.new(prev, noun, flip: prev.at_tail?)
      return noun unless prev = noun.prev?
    end

    return noun unless prev.pronouns?
    PairNode.new(prev, noun, flip: noun.tag.posit?)
  end
end
