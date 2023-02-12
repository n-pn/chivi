module M1::TlRule
  def fold_verb_compare(head : MtNode) : MtNode?
    return nil unless succ = head.succ?

    case head.key
    when "如", "像"
      fold_compare(head, succ, "tựa")
    when "仿佛", "宛若"
      fold_compare(head, succ, "giống")
    when "好像"
      fold_compare(head, succ, "thật giống")
    else
      nil
    end
  end

  def fold_compare(head : MtNode, tail : MtNode, head_val = head.val)
    while tail
      return if tail.puncts? || tail.key == head.key

      if tail.uyy?
        break unless tail.key == "一样"
        break unless tail.prev?(&.adv_bu4?)
      end

      tail = tail.succ?
    end

    return unless tail && tail != head.succ?

    head.val = head_val
    tail.val = "như" if tail.key.in?("一样", "似的", "一般", "般")

    tail_2 = tail.prev
    tail_2.fix_succ!(tail.succ?)
    tail.fix_succ!(head.succ?)
    head.fix_succ!(tail)

    root = fold!(head, tail_2, tag: PosTag::Aform, dic: 0)
    fix_grammar!(tail)
    root.regen_list!

    return root unless succ = scan_adjt!(root.succ?)
    return root unless succ.adjective? || succ.verb_object?

    fold!(root, succ, PosTag::Aform, dic: 1, flip: true)
  end
end
