module MtlV2::TlRule
  def fold_第!(node : BaseNode)
    return node unless (succ = node.succ?) && (succ.nhanzis? || succ.ndigits?)

    if succ.key == "一"
      succ.val = "nhất"
      node.val = "đệ" if node.prev?(&.nominal?)
    end

    head = fold!(node, succ, PosTag::Noun, dic: 3)

    return head unless tail = head.succ?
    tail = heal_quanti!(tail)

    case tail.tag
    when .noun?, .temporal?, .ptitle?, .nattr?, .affil?
      fold!(head, tail, tail.tag, dic: 8, flip: true)
    when .quantis?
      if (tail_2 = tail.succ?) && tail_2.nominal?
        tail = fold!(tail, tail_2, PosTag::NounPhrase, dic: 7)
        fold!(head, tail, tail.tag, dic: 6, flip: true)
      else
        fold!(head, tail, PosTag::Nqnoun, flip: true)
      end
    else
      head
    end
  end
end
