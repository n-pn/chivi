module CV::TlRule
  def fold_adverbs!(node : MtNode, succ = node.succ?) : MtNode
    case node.tag
    when .adv_bu?  then fold_adv_bu!(node, succ)
    when .adv_mei? then fold_adv_mei!(node, succ)
    when .adv_fei? then fold_adv_fei!(node, succ)
    else                fold_adverb!(node, succ)
    end
  end

  def fold_adv_bu!(node : MtNode, succ = node.succ?) : MtNode
    return node unless succ

    case succ.tag
    when .vmodals? then heal_vmodal!(succ, nega: node)
    when .verbs?   then fold_verbs!(succ, nega: node)
    else                fold_adverb!(succ, nega: node)
    end
  end

  def fold_adv_mei!(node : MtNode, succ = node.succ?) : MtNode
    return node unless succ

    case succ.tag
    when .verbs? then fold_verbs!(succ, nega: node)
    when .adjts?
      node.val = "không"
      fold_adjts!(succ, nega: node)
    else
      node.val = "không có"
      node
    end
  end

  def fold_adv_fei!(node : MtNode, succ = node.succ?) : MtNode
    return node unless succ
    # TODO: check for key when 没 mean "không"
    fold_verbs!(succ, nega: node)
  end

  def fold_adverb!(node : MtNode, succ = node.succ?, nega : MtNode? = nil) : MtNode
    # TODO: merge adverb with adjectives or verbs
    node.fold_left!(nega)
  end
end
