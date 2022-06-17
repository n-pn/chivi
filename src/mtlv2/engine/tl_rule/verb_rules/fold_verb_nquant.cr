module MtlV2::TlRule
  def fold_verb_nquant!(verb : BaseNode, tail : BaseNode, has_ule = false)
    tail = fold_number!(tail) if tail.numbers?
    return verb unless tail.nquants?

    if tail.nqiffy? || tail.nqnoun?
      return verb if has_ule || !is_temp_nqverb?(tail)
    end

    fold!(verb, tail, verb.tag, dic: 6)
  end

  def is_temp_nqverb?(tail : BaseNode)
    case tail.key[-1]?
    when '把'
      return false if tail.succ?(&.noun?)
      tail.val = tail.val.sub(/bả|chiếc/, "phát")
      true
    when '脚', '眼', '圈', '次' # , '口'
      true
    else
      false
    end
  end
end
