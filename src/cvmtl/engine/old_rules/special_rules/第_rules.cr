module MT::TlRule
  def fold_第!(node : MtNode)
    return node unless (succ = node.succ?) && (succ.nhanzis? || succ.ndigits?)

    succ.val = "nhất" if succ.key == "一"
    head = fold!(node, succ, PosTag::Noun)

    return head unless tail = head.succ?
    tail = heal_quanti!(tail)

    case tail.tag
    when .common_nouns?, .all_times?, .honor?, .nattr?, .cap_affil?
      node.val = "đệ" if head.prev?(&.all_nouns?)
      fold!(head, tail, tail.tag, flip: true)
    when .quantis?
      if (tail_2 = tail.succ?) && tail_2.all_nouns?
        tail = fold!(tail, tail_2, PosTag::Nform)
        fold!(head, tail, tail.tag, flip: true)
      else
        fold!(head, tail, PosTag::Nqnoun, flip: true)
      end
    else
      head
    end
  end
end
