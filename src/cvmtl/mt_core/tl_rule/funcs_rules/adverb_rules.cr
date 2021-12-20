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
    case succ
    when .nil? then node
    when .modifier?, .noun?, .ajno?, .veno?
      node = fold!(node, succ, PosTag::Modifier, dic: 7)
      fold_adjts!(node)
    when .verbs?
      fold_verbs!(succ, prev: node)
    else
      node.set!("không phải là")
    end

    # TODO: check for key when 没 mean "không"
  end

  def fold_adverb!(node : MtNode, succ = node.succ?, nega : MtNode? = nil) : MtNode
    node = fold!(nega, node, PosTag::Adverb, dic: 2) if nega

    return node unless succ
    node.val = "vậy" if !nega && succ.ends? && node.key == "也"

    case succ.tag
    when .v_you?
      return node unless (noun = succ.succ?) && noun.noun?
      succ = fold!(succ, noun, PosTag::Aform, dic: 5)
      fold_adverb_node!(node, succ)
    when .vmodals?
      heal_vmodal!(succ, nega: node)
    when .verbs?
      succ.tag = PosTag::Verb if succ.veno? || succ.vead?
      fold_verbs!(succ, prev: node)
    when .adjts?
      succ.tag = PosTag::Adjt if succ.ajno? || succ.ajad?
      fold_adjts!(succ, prev: node)
    when .adv_bu?
      succ = fold_adv_bu!(succ)
      fold!(node, succ, succ.tag, dic: 2)
    when .space?
      return node unless node.key = "最"
      return fold!(node, succ, succ.tag, dic: 7, flip: true)
    when .preposes?
      succ = fold_preposes!(succ)
      fold!(node, succ, succ.tag, dic: 2)
    else node
    end
  end

  def fold_adverb_node!(adv : MtNode, node = adv.succ, tag = node.tag, dic = 4) : MtNode
    flip = false

    case adv.key
    when "不太"
      # TODO: just delete this entry
      head = MtNode.new("不", "không", PosTag::AdvBu, 1, adv.idx)
      tail = MtNode.new("太", "lắm", PosTag::Adverb, 1, adv.idx + 1)

      node.set_prev!(head)
      node.set_succ!(tail)

      return fold!(head, tail, PosTag::Aform, dic: dic)
    when "最", "最为", "那么", "这么", "非常", "如此"
      flip = true
    when "十分" then adv.val = "vô cùng"
    when "挺"  then adv.val = "rất"
    end

    fold!(adv, node, tag, dic: dic, flip: flip)
  end
end
