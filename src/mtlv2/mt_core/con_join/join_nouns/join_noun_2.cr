module MT::Core
  def join_noun_2!(noun : BaseNode, prev = noun.prev) : BaseNode
    if prev.adjt_words?
      noun = BasePair.new(prev, noun, noun.tag, flip: !prev.at_head?)
      prev = noun.prev
    end

    if prev.pt_deps?
      prev = join_udep!(prev)
      noun = BasePair.new(prev, noun, noun.tag, flip: true)
      prev = noun.prev
    end

    if prev.quantis? || prev.nquants?
      prev.as(BaseTerm).inactivate! if prev.tag.qt_ge4?
      noun = fold!(prev, noun, noun.tag, flip: false)
      prev = noun.prev
    end

    if prev.numbers?
      noun = fold!(prev, noun, noun.tag, flip: prev.ordinal?)
      return noun unless prev = noun.prev?
    end

    if prev.pro_dems? || prev.pro_na2?
      noun = fold!(prev, noun, noun.tag, flip: prev.at_tail?)
      return noun unless prev = noun.prev?
    end

    return noun unless prev.pronouns?
    fold!(prev, noun, tag: noun.tag, flip: noun.tag.posit?)
  end
end
