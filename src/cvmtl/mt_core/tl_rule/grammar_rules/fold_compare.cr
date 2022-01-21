module CV::TlRule
  def fold_compare(head : MtNode, tail = head.succ?)
    while tail
      return if tail.puncts? || tail.key == "像"
      break if tail.uyy?
      tail = tail.succ?
    end

    return unless tail && tail != head.succ?

    case tail.key
    when "一样", "似的", "一般"
      tail.val = "như"
    end

    root = fold!(head, tail, tag: PosTag::Aform, dic: 0)

    tail.prev.set_succ!(nil)
    fix_grammar!(head.succ, level: 1)
    root.body.set_succ!(tail)

    return root unless (succ = root.succ?)

    if succ.maybe_adjt?
      succ = succ.adverbs? ? fold_adverbs!(succ) : fold_adjts!(succ)
      return fold!(root, succ, PosTag::Aform, dic: 7, flip: true)
    end

    if succ.key.in?("爱", "喜欢")
      succ = fold_verbs!(succ.set!(PosTag::Verb))

      if succ.verb_object? || succ
        tail.val = ""
        return fold!(root, succ, succ.tag, dic: 8, flip: true)
      end
    end

    root
  end
end
