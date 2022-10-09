module MT::TlRule
  def fold_第!(node : BaseNode)
    return node unless (succ = node.succ?) && (succ.nhanzis? || succ.ndigits?)

    succ.val = "nhất" if succ.key == "一"
    head = fold!(node, succ, MapTag::Noun, dic: 3)

    return head unless tail = head.succ?
    tail = heal_quanti!(tail)

    case tail.tag
    when .common_nouns?, .time_words?, .honor?, .nattr?, .cap_affil?
      node.val = "đệ" if head.prev?(&.noun_words?)
      fold!(head, tail, tail.tag, dic: 8, flip: true)
    when .quantis?
      if (tail_2 = tail.succ?) && tail_2.noun_words?
        tail = fold!(tail, tail_2, MapTag::Nform, dic: 7)
        fold!(head, tail, tail.tag, dic: 6, flip: true)
      else
        fold!(head, tail, MapTag::Nqnoun, flip: true)
      end
    else
      head
    end
  end
end
