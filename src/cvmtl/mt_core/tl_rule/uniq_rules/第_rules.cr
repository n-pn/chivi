module CV::TlRule
  def fold_第!(node : MtNode)
    return node unless succ = node.succ?
    return node unless succ.nhanzi? || succ.ndigit?

    succ.val = "nhất" if succ.key == "一"
    head = fold!(node, succ, PosTag::Noun, dic: 3)

    return head unless tail = head.succ?
    tail = heal_quanti!(tail)

    case tail.tag
    when .noun?, .time?, .ptitle?
      node.val = "đệ" if node.prev?(&.nouns?)

      head = fold!(head, tail, tail.tag, dic: 8, flip: true)
      fold_nouns!(head)
    when .quantis?
      if (tail_2 = tail.succ?) && tail_2.nouns?
        tail = fold!(tail, tail_2, PosTag::NounPhrase, dic: 7)
        fold!(head, tail, tail.tag, dic: 6, flip: true)
      else
        fold!(head, tail, PosTag::Nqnoun, flip: true)
      end
    else
      node
    end
  end
end
