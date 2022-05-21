module CV::TlRule
  def fold_verb_compare(head : MtNode) : MtNode?
    case head.key
    when "如", "像"
      fold_compare(head.set!("tựa"))
    when "仿佛", "宛若"
      fold_compare(head.set!("giống"))
    when "好像"
      fold_compare(head.set!("thật giống"))
    else
      nil
    end
  end

  def fold_compare(head : MtNode, tail = head.succ?)
    while tail
      return if tail.puncts? || tail.key == "像"

      if tail.uyy?
        break unless tail.key == "一样"
        break unless tail.prev?(&.adv_bu4?)
      end

      tail = tail.succ?
    end

    return unless tail && tail != head.succ?

    tail.val = "như" if tail.key.in?("一样", "似的", "一般", "般")

    root = fold!(head, tail, tag: PosTag::Aform, dic: 0)
    tail.prev.fix_succ!(nil)
    fix_grammar!(head, level: 1)
    head.set_succ!(tail)

    return root unless succ = scan_adjt!(root.succ?)
    return root unless succ.adjts? || succ.verb_object?

    fold!(root, succ, PosTag::Aform, dic: 1, flip: true)
  end
end
