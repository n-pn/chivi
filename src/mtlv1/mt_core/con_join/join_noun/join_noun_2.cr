module CV::TlRule
  def join_noun_2!(noun : BaseNode, prev = noun.prev) : BaseNode
    ptag = noun.tag.posit? ? noun.tag : PosTag::Nform

    if prev.adjt_words?
      noun = fold_noun_adjt_left!(noun, prev)
      return noun unless prev = noun.prev?
    end

    if prev.quantis? || prev.nquants?
      prev.val = "" if prev.key == "个"
      noun = fold!(prev, noun, ptag, flip: false)
      return noun unless prev = noun.prev?
    end

    if prev.numbers?
      noun = fold!(prev, noun, ptag, flip: prev.ordinal?)
      return noun unless prev = noun.prev?
    end

    if prev.pro_dems? || prev.pro_na2?
      flip = should_flip_pro_dems?(prev)
      noun = fold!(prev, noun, ptag, flip: flip)
      return noun unless prev = noun.prev?
    end

    return noun unless prev.pronouns?
    fold!(prev, noun, ptag, flip: ptag.posit?)
  end
end
