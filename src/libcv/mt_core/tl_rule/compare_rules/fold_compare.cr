module CV::TlRule
  def fold_compare(head : MtNode, tail = head.succ?)
    while tail
      return if tail.puncts? || tail.key == "像"

      if tail.uyy?
        break unless tail.key == "一样"
        break unless tail.prev?(&.adv_bu4?) || tail.succ?(&.ude1?)
      end

      tail = tail.succ?
    end

    return unless tail && tail != head.succ?

    MtDict.v_compare.get_val(head.key).try { |x| head.val = x }
    tail.val = "như" if tail.key.in?("一样", "似的", "一般", "般")

    root = fold!(head, tail, tag: PosTag::AdjtPhrase, dic: 0)
    tail.prev.fix_succ!(nil)
    fix_grammar!(head)
    head.set_succ!(tail)

    return root unless succ = scan_adjt!(root.succ?)
    return root unless succ.adjective? || succ.verb_object?

    fold!(root, succ, PosTag::Aform, dic: 1, flip: true)
  end
end
