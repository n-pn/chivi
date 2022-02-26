module CV::TlRule
  def fold_adverbs!(node : MtNode, succ = node.succ?) : MtNode
    if !succ || succ.ends?
      node.val = "vậy" if node.key == "也"
      return node
    end

    # puts [node, succ]

    case node.tag
    when .adv_bu?  then return fold_adv_bu!(node, succ)
    when .adv_mei? then return fold_adv_mei!(node, succ)
    when .adv_fei? then return fold_adv_fei!(node, succ)
    when .vead?
      return fold_verbs!(MtDict.fix_verb!(node)) if succ.nouns?
    end

    fold_adverb_base!(node, succ)
  end

  def fold_adv_bu!(node : MtNode, succ = node.succ) : MtNode
    case succ.tag
    when .vmodals?
      fold_vmodals!(succ, nega: node)
    when .pre_dui?
      succ = fold_pre_dui!(succ)
      fold!(node, succ, succ.tag, dic: 9)
    when .adverbs?
      node = fold!(node, succ, succ.tag, dic: 4)
      return node unless succ = node.succ?
      fold_adverb_base!(node, succ)
    when .verbs?
      succ = MtDict.fix_verb!(succ) if succ.veno?
      node = fold!(node, succ, succ.tag, dic: 4)
      fold_verbs!(node)
    when .adjts?
      succ = MtDict.fix_adjt!(succ) if succ.ajno?
      node = fold!(node, succ, succ.tag, dic: 5)
      fold_adjts!(node)
    else
      node
    end
  end

  def fold_adv_mei!(node : MtNode, succ = node.succ) : MtNode
    case succ.tag
    when .verbs?
      succ = heal_veno!(succ) if succ.veno?
      # TODO: add more cases
      node.val = succ.succ?(&.uzhe?) ? "không" : node.prev?(&.subject?) ? "chưa" : "không có"
      fold_verbs!(succ, prev: node)
    when .adjt?, .ajad?, .ajno?
      fold!(node.set!("không"), succ, PosTag::Adjt, dic: 2)
    else
      node
    end
  end

  def fold_adv_fei!(node : MtNode, succ = node.succ) : MtNode
    case succ
    when .modifier?, .noun?, .ajno?, .veno?
      node = fold!(node, succ, PosTag::Modifier, dic: 7)
      fold_adjts!(node)
    when .verbs?
      node = fold!(node, succ, succ.tag, dic: 6)
      fold_verbs!(node)
    else
      node.set!("không phải là")
    end

    # TODO: check for key when 没 mean "không"
  end

  # ameba:disable Metrics/CyclomaticComplexity
  def fold_adverb_base!(node : MtNode, succ = node.succ) : MtNode
    if succ.vead? || succ.ajad?
      if is_adverb?(succ)
        node = fold!(node, succ, PosTag::Adverb, dic: 5)
        return node unless succ = node.succ?
      elsif succ.vead?
        succ = MtDict.fix_verb!(succ)
      else
        succ = MtDict.fix_adjt!(succ)
      end
    end

    case succ.tag
    when .v_you?
      return node unless (noun = succ.succ?) && noun.noun?
      succ = fold!(succ, noun, PosTag::Aform, dic: 5)
      fold_adverb_node!(node, succ)
    when .vmodals?
      fold_vmodals!(succ, nega: node)
    when .veno?
      fold_adverb_verb!(node, MtDict.fix_verb!(succ))
    when .verbs?
      fold_adverb_verb!(node, succ)
    when .adjts?
      succ.tag = PosTag::Adjt if succ.ajno? || succ.ajad?
      fold_adjts!(succ, prev: node)
    when .adv_bu?
      if tail = succ.succ?
        succ = fold_adv_bu!(succ, tail)
      end
      fold!(node, succ, succ.tag, dic: 2)
    when .adverb?
      node = fold!(node, succ, succ.tag, dic: 6)
    when .space?
      return node unless node.key = "最"
      fold!(node, succ, succ.tag, dic: 7, flip: true)
    when .preposes?
      succ = fold_preposes!(succ)
      fold!(node, succ, succ.tag, dic: 2)
    else
      case node
      when .vead?
        fold_verbs!(MtDict.fix_verb!(node))
      when .ajad?
        fold_adjts!(MtDict.fix_adjt!(node))
      else
        node
      end
    end
  end

  def fold_adverb_verb!(adverb : MtNode, verb : MtNode)
    case adverb.key
    when "光" then adverb.val = "chỉ riêng"
    when "白" then adverb.val = "phí công"
    when "正" then adverb.val = "đang" unless verb.v_shi?
    end

    fold_verbs!(verb, prev: adverb)
  end

  def is_adverb?(node : MtNode) : Bool
    while node = node.succ?
      case node
      when .comma?
        return false unless node = node.succ?
      when .plsgn?, .mnsgn?, .verbs?, .preposes?, .adjts?, .adverbs?
        return true
      when .concoord?
        return false unless node.key == "和"
        # TODO: deep checking
        return true
      else
        return false
      end
    end

    false
  end
end
