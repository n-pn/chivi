module M1::TlRule
  def fold_verb_nquant!(verb : MtNode, tail : MtNode, has_ule = false)
    tail = fuse_number!(tail) if tail.numbers?
    return verb unless tail.nquants?

    if tail.nqiffy? || tail.nqnoun?
      return verb if has_ule || tail.tag.nqvcpl?
    end

    fold!(verb, tail, verb.tag, dic: 6)
  end
end
