module MtlV2::MTL
  def fold_noun_left!(curr : HonorWord, left : NounWord)
    case left
    when HonorWord, HumanName, AffilName, BasicNoun
      left.set_succ(curr.succ?)
      left.key += succ.key
      left.val = succ.apply_honor(left.val)
      left
    else
      NounPair.new(left, curr, flip: false)
    end
  end

  def fold_noun_left!(curr : LocatNoun, left : NounWord)
    case left
    when TimeWord
      TimePair.new(left, curr, flip: true)
    else
      PositPair.new(left, curr, flip: true)
    end
  end

  def fold_noun_left!(curr : PositPair | PositNoun, left : NounWord)
    case left
    when TimeWord
      NounPair.new(left, curr, flip: false)
    else
      PositPair.new(left, curr)
    end
  end

  def fold_noun_left!(curr : TraitNoun | TraitPair, left : NounWord)
    TraitPair.new(left, curr, flip: true)
  end

  def fold_noun_left!(curr : BaseNode, left : NounWord)
    case left
    when TraitNoun, PositNoun
      NounPair.new(left, curr, flip: true)
    else
      NounPair.new(left, curr, flip: false)
    end
  end

  def fold_noun_left!(curr : BaseNode, left : NquantWord | QuantiWord)
    return left unless left.for_noun?

    if !curr.is_a?(NounForm)
      curr = NounForm.new(curr)
    elsif curr.qti_mod
      return NounPair.new(left, curr, flip: false)
    end

    left = left.as_quanti!
    curr.set_prev?(left.prev?)
    curr.qti_mod = left

    curr
  end

  def fold_noun_left!(curr : BaseNode, left : NumberWord | NumberExpr)
    curr = NounForm.new(curr) unless curr.is_a?(NounForm)

    if !curr.is_a?(NounForm)
      curr = NounForm.new(curr)
    elsif curr.num_mod
      return NounPair.new(left, curr, flip: false)
    elsif nquant = curr.qti_mod
      return NounPair.new(left, curr, flip: false) if !nquant.is_a?(QuantiWord)
    end

    curr.set_prev?(left.prev?)
    curr.num_mod = left

    curr
  end

  def fold_noun_left!(curr : BaseNode, left : ProdemWord)
    curr = NounForm.new(curr) unless curr.is_a?(NounForm)

    if !curr.is_a?(NounForm)
      curr = NounForm.new(curr)
    elsif curr.dem_mod
      return NounPair.new(left, curr, flip: false)
    elsif curr.qti_mod
      return NounPair.new(left, curr, flip: false) if left.has_quanti?
    end

    curr.set_prev?(left.prev?)
    curr.dem_mode = left

    curr
  end

  def fold_noun_left!(curr : BaseNode, left : BaseNode)
    left
  end
end
