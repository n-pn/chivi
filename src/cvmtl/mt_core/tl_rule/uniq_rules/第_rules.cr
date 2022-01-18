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
      node = fold!(node, succ, succ.tag, dic: 8, flip: true)
      fold_nouns!(node)
    when .quantis?
      if (succ_2 = succ.succ?) && succ_2.nouns?
        succ = fold!(succ, succ_2, PosTag::NounPhrase, dic: 7)
        fold!(node, succ, succ.tag, dic: 6, flip: true)
      else
        fold!(node, succ, PosTag::Noun, flip: true)
      end
    else
      node
    end
  end
end
