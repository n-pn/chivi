module CV::TlRule
  def fold_verb_nquant!(verb : MtNode, tail : MtNode, has_ule = false)
    tail = fuse_number!(tail) if tail.numbers?
    return verb unless tail.nquants?

    if tail.nqiffy? || tail.nqnoun?
      return verb if has_ule || !nquant_is_compl?(tail)
    end

    fold!(verb, tail, verb.tag, dic: 6)
  end

  def nquant_is_compl?(node : MtTerm) : Bool
    case node.key[-1]?
    when '脚', '眼', '圈', '次' # , '口'
      true
    when '把'
      return false if node.succ?(&.nominal?)
      node.val = node.val.sub(/bả|chiếc/, "phát")
      true
    else
      false
    end
  end

  def nquant_is_compl?(node : MtList) : Bool
    node.list.any? { |x| nquant_is_compl?(x) }
  end
end
