module CV::TlRule
  def fold_compare(head : MtNode, tail = head.succ?)
    while tail
      return if tail.puncts?
      break if tail.uyy?
      tail = tail.succ?
    end

    return unless tail && tail != head.succ?

    case tail.key
    when "一样"
      tail.val = "như là"
    when "似的", "一般"
      tail.val = "như"
    end

    root = fold!(head, tail, tag: PosTag::Aform, dic: 0)

    tail.prev.set_succ!(nil)
    fix_grammar!(head.succ, level: 1)
    root.body.set_succ!(tail)

    root
  end
end
