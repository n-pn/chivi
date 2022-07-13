module MtlV2::AST::Rules
  def fold_left!(right : AdjtWord | AdjtList, left : AdjtWord)
    adjt = AdjtTuple.new(left, right)
    fold_left!(adjt, adjt.prev?)
  end

  def fold_left!(right : AdjtForm, left : AdjtWord)
    left = fold_left!(right: left, left: left.prev?)
    AdjtList.new(left, right)
  end

  def fold_left!(right : AdjtWord | AdjtTuple, left : AdavWord)
    adjt = AdjtPhrase.new(adjt: right, adav: left)
    fold_left!(right: adjt, left: adjt.prev?)
  end

  def fold_left!(right : AdjtForm, left : AdavWord)
    right.add_adav!(left)
    fold_left!(right, right.prev?)
  end
end
