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
    when .predui?
      succ = heal_predui!(succ)
      node.tag = succ.tag
      node.fold!(succ, "#{node.val} #{succ.val}")
    when .vmodals? then heal_vmodal!(succ, nega: node)
    when .adverb?  then fold_adverb!(succ, nega: node)
    when .verbs?   then fold_verbs!(succ, prev: node)
    when .adjts?   then fold_adjts!(succ, prev: node)
    else                node
    end
  end

  def fold_adv_mei!(node : MtNode, succ = node.succ?) : MtNode
    return node unless succ

    case succ.tag
    when .verbs?
      node.val = succ.succ?(&.uzhe?) ? "không" : "chưa"
      fold_verbs!(succ, node)
    when .adjt?, .ajav?, .ajno?
      node.val = "không"
      node.tag = PosTag::Adjt

      succ = fold_adjts!(succ)
      node.fold!(succ)
    else
      node
    end
  end

  def fold_adv_fei!(node : MtNode, succ = node.succ?) : MtNode
    return node unless succ
    # TODO: check for key when 没 mean "không"
    fold_verbs!(succ, node)
  end

  def fold_adverb!(node : MtNode, succ = node.succ?, nega : MtNode? = nil) : MtNode
    return node unless succ
    node.val = "vậy" if !nega && succ.ends? && node.key == "也"

    case succ.tag
    when .verbs?
      node = fold_verbs!(succ, prev: node)
    when .adjts?
      node = fold_adjts!(succ, prev: node)
    end

    node.fold_left!(nega)
  end
end
