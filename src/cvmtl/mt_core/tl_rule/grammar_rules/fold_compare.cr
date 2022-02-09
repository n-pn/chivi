module CV::TlRule
  def fold_compare(head : MtNode, tail = head.succ?)
    while tail
      return if tail.puncts? || tail.key == "像"
      break if tail.uyy?
      tail = tail.succ?
    end

    return unless tail && tail != head.succ?

    head.each do |x|
      case x.key
      when "仿佛" then x.val = "giống"
      when "如"  then x.val = "tựa"
      end
    end

    case tail.key
    when "一样", "似的", "一般", "般"
      tail.val = "như"
    end

    root = fold!(head, tail, tag: PosTag::Aform, dic: 0)
    tail.prev.fix_succ!(nil)
    fix_grammar!(head, level: 1)
    head.set_succ!(tail)

    return root unless succ = scan_adjt!(root.succ?)
    return root unless succ.adjts? || succ.verb_object?

    return fold!(root, succ, PosTag::Aform, dic: 1, flip: true)
  end
end
