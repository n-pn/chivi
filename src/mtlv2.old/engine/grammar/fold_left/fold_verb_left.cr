require "./fold_advb_left"

module MtlV2::MTL
  def fold_verb_left!(curr : Verbal, left : BaseNode, lvl = 0)
    if advb = fold_verb_advb(left)
      curr = VerbForm.new(curr)
      curr.add_advb(advb)
      return curr unless left = curr.prev?
    end

    # TODO: add with other types
    curr
  end

  def fold_verb_advb(left : BaseNode)
    case left
    when Adverbial then fold_advb_left!(left, left.prev?)
    when Adjective
      left.prev?.try { |x| left = fold_adjt_left!(left, x) }
      return left if left.attr.verb_adv?
    when PtclDe2
      if (prev = left.prev? { |x| fold_left!(x, x.prev?) }) && can_be_advb?(prev)
        return Ude2Pair.new(prev, left)
      end

      left.as_noun!
      nil
    when Onomat then left
      # when Pronoun
      # TODO: “这么”，“那么”，“这样”，“那样”，“多么”
      # When PlaceWord ?
    when TimeWord
      # TODO: fold time
      left
    else nil
    end
  end

  def can_be_advb?(prev : BaseNode)
    case prev
    when Adjective, Adverbial, Onomat
      true
    when Verbal
      !prev.is_a?(VShiWord) && !prev.is_a?(VYouWord)
    else false
    end
  end
end
