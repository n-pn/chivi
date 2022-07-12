module MtlV2::AST::Rules
  def fold_left!(adjt : AdjtWord | AdjtTuple, left : AdavWord)
    adjt = AdjtPhrase.new(adjt, adav: left)
    fold_left!(adjt, adjt.prev?)
  end

  def fold_left!(adjt : AdjtPhrase, left : AdavWord)
    adjt.add_adav!(left)
    fold_left!(adjt, adjt.prev?)
  end

  def fold_left!(adjt : AjdtWord, left : AdjtWord)
    adjt = AdjtTuple.new(left, adjt)
    fold_left!(adjt, adjt.prev?)
  end

  def fold_left!(adjt : AdjtWord | AdjtTuple | AdjtPhrase, left : Conjunct)
    return adjt unless left.type.phrase? && (head = left.prev?) && head.is_a?(AdjtWord)
    adjt = AdjtTuple.new(head, left, adjt, mark: 4)
    fold_left!(adjt, ajdt.left?)
  end
end
