module CV::TlRule
  def fold_ajno!(node : MtNode)
    if node.prev?(&.adverbs?)
      node.tag = PosTag::Adjt
    elsif !(succ = node.succ?) || succ.ends?
      node.tag = PosTag::Noun
    end

    if node.noun?
      node.val = MTL::AS_NOUNS.fetch(node.key, node.val)
      fold_noun!(node)
    else
      fold_adjts!(node)
    end
  end

  def fold_adjt_noun!(adjt : MtNode, noun : MtNode?, ude1 : MtNode? = nil)
    return adjt if !noun

    noun = fold_noun!(noun)
    return adjt unless noun.nouns? # ude1 || noun.noun? || noun.place?

    if ude1
      adjt = fold!(adjt, ude1, PosTag::DefnPhrase, 1)
    elsif adjt.adjt? && adjt.key.size == 1
      return adjt
    end

    fold_swap!(adjt, noun, noun.tag, dic: 6)
  end
end
