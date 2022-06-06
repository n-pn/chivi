module CV::TlRule
  def fold_verb_nquant!(verb : MtNode, tail : MtNode, has_ule = false)
    tail = fold_number!(tail) if tail.numbers?
    return verb unless tail.nquants?

    if tail.nqiffy? || tail.nqnoun?
      return verb if has_ule || !is_temp_nqverb?(tail)
    end

    fold!(verb, tail, verb.tag, dic: 6)
  end

  def is_temp_nqverb?(tail : MtNode)
    tail.each do |x|
      case x.key[-1]?
      when '把'
        next false if tail.succ?(&.noun?)
        x.val = x.val.sub(/bả|chiếc/, "phát")
      when '脚', '眼', '圈', '次' # , '口'
        next true
      end
    end

    false
  end
end
