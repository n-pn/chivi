module MtlV2::MTL
  def fold_adjt_left!(right : Adjective, left : AdjtWord)
    adjt = AdjtForm.new(left, right) unless adjt.is_a?(AdjtForm)

    fold_adjt_left!(adjt, adjt.prev?)
  end

  def fold_adjt_left!(right : AdjtForm, left : AdjtWord)
    left = fold_adjt_left!(right: left, left: left.prev?)
    AdjtList.new(left, right)
  end

  def fold_adjt_left!(right : AdjtWord | AdjtTuple, left : AdavWord)
    adjt = AdjtPhrase.new(adjt: right, adav: left)
    fold_left!(right: adjt, left: adjt.prev?)
  end

  def fold_adjt_left!(right : AdjtForm, left : AdavWord)
    right.add_adav!(left)
    fold_left!(right, right.prev?)
  end
end
