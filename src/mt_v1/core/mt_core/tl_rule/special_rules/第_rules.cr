module M1::TlRule
  def fold_第!(node : MtNode)
    return node unless (succ = node.succ?) && (succ.nhanzi? || succ.ndigit?)

    succ.val = "nhất" if succ.key == "一"
    head = fold!(node, succ, PosTag::Noun, dic: 3)

    return head unless tail = head.succ?
    tail = heal_quanti!(tail)

    case tail.tag
    when .noun?, .ntime?, .honor?, .nattr?, .naffil?
      node.val = "đệ" if head.prev?(&.nominal?)
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
