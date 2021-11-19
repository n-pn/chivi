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
    when .vmodals?
      heal_vmodal!(succ, nega: node)
    when .pre_dui?
      succ = fold_pre_dui!(succ)
      fold!(node, succ, succ.tag, dic: 9)
    when .adverb?
      node = fold!(node, succ, succ.tag, dic: 4)
      fold_adverb!(node)
    when .verbs?
      succ.set!(PosTag::Verb) if succ.veno?
      node = fold!(node, succ, succ.tag, dic: 4)
      fold_verbs!(node)
    when .adjts?
      succ.set!(PosTag::Adjt) if succ.ajno?
      node = fold!(node, succ, succ.tag, dic: 5)
      fold_adjts!(node)
    else
      node
    end
  end

  def fold_adv_mei!(node : MtNode, succ = node.succ?) : MtNode
    return node unless succ

    case succ.tag
    when .veno?
      succ = heal_veno!(succ)
      succ.noun? ? node.set!("không có") : fold_verbs!(succ, prev: node.set!("chưa"))
    when .verbs?
      node.val = succ.succ?(&.uzhe?) ? "không" : "chưa"
      fold_verbs!(succ, prev: node)
    when .adjt?, .ajad?, .ajno?
      fold!(node.set!("không"), succ, PosTag::Adjt, dic: 2)
    else
      node
    end
  end

  def fold_adv_fei!(node : MtNode, succ = node.succ?) : MtNode
    return node unless succ
    # TODO: check for key when 没 mean "không"
    fold_verbs!(succ, prev: node)
  end

  def fold_adverb!(node : MtNode, succ = node.succ?, nega : MtNode? = nil) : MtNode
    node = fold!(nega, node, PosTag::Adverb, dic: 2) if nega

    return node unless succ
    node.val = "vậy" if !nega && succ.ends? && node.key == "也"

    case succ.tag
    when .veno?
      succ.tag = PosTag::Verb
      fold_verbs!(succ, prev: node)
    when .verbs?
      fold_verbs!(succ, prev: node)
    when .adjts?
      fold_adjts!(succ, prev: node)
    when .adv_bu?
      succ = fold_adv_bu!(succ)
      fold!(node, succ, succ.tag, dic: 3)
    when .space?
      return node unless node.key = "最"
      return fold_swap!(node, succ, succ.tag, dic: 7)
    when .preposes?
      succ = fold_preposes!(succ)
      fold!(node, succ, succ.tag, dic: 2)
    else node
    end
  end
end
