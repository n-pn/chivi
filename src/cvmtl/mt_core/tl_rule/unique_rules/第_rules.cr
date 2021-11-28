module CV::TlRule
  def fold_第!(node : MtNode)
    return node unless succ = node.succ?
    return node unless succ.nhanzi? || succ.ndigit?

    if succ.key == "一"
      succ.val = "nhất"
      node.val = "đệ" if node.prev?(&.nouns?)
    end

    node = fold!(node, succ, PosTag::Noun, dic: 3)
    return node unless succ = node.succ?
    succ = heal_quanti!(succ)

    case succ.tag
    when .noun?, .time?, .ptitle?
      node = fold_swap!(node, succ, succ.tag, dic: 8)
      fold_noun!(node)
    when .quantis?
      if (succ_2 = succ.succ?) && succ_2.nouns?
        succ = fold!(succ, succ_2, PosTag::Nphrase, dic: 7)
        fold_swap!(node, succ, succ.tag, dic: 6)
      else
        fold_swap!(node, succ, PosTag::Noun)
      end
    else
      node
    end
  end
end
