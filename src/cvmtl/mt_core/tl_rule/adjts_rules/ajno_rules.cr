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

    noun = scan_noun!(noun)

    return adjt unless noun.nouns? || noun.nquants?

    if ude1
      ude1.val = ""
      adjt = fold!(adjt, ude1, PosTag::DefnPhrase, 1)
    elsif adjt.adjt? && adjt.key.size == 1
      return adjt
    end

    fold_swap!(adjt, noun, noun.tag, dic: 6)
  end
end
