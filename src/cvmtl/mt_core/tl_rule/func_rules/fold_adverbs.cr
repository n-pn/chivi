module CV::TlRule
  def fold_adverbs!(node : MtNode, succ = node.succ?) : MtNode
    case node.tag
    when .adv_bu?  then fold_adv_bu!(node, succ)
    when .adv_mei? then fold_adv_mei!(node, succ)
    when .adv_fei? then fold_adv_fei!(node, succ)
    else                fold_adverb_base!(node, succ)
    end
  end

  def fold_adv_bu!(node : MtNode, succ = node.succ?) : MtNode
    return node unless succ

    case succ.tag
    when .vmodals?
      fold_vmodals!(succ, nega: node)
    when .pre_dui?
      succ = fold_pre_dui!(succ)
      fold!(node, succ, succ.tag, dic: 9)
    when .adverb?
      node = fold!(node, succ, succ.tag, dic: 4)
      fold_adverb_base!(node)
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
    succ = heal_veno!(succ) if succ.veno?

    case succ.tag
    when .verbs?
      # TODO: add more cases
      node.val = succ.succ?(&.uzhe?) ? "không" : node.prev?(&.subject?) ? "chưa" : "không có"
      node = fold!(node, succ, succ.tag, dic: 7)
      fold_verbs!(node)
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
      node = fold!(node, succ, succ.tag, dic: 6)
      fold_verbs!(node)
    else
      node.set!("không phải là")
    end

    # TODO: check for key when 没 mean "không"
  end

  def fold_adverb_base!(node : MtNode, succ = node.succ?, nega : MtNode? = nil) : MtNode
    node = fold!(nega, node, PosTag::Adverb, dic: 2) if nega

    return node unless succ
    node.val = "vậy" if !nega && succ.ends? && node.key == "也"

    if succ.vead?
      if (tail = succ.succ?) && (tail.verbs? || tail.preposes? || tail.key == "和")
        node = fold!(node, succ, succ.tag, dic: 5)
        return node unless succ = node.succ?
      else
        return fold_adverb_verb!(node, cast_verb!(succ))
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
      fold_adverb_verb!(node, cast_verb!(succ))
    when .verbs?
      fold_adverb_verb!(node, succ)
    when .adjts?
      succ.tag = PosTag::Adjt if succ.ajno? || succ.ajad?
      fold_adjts!(succ, prev: node)
    when .adv_bu?
      succ = fold_adv_bu!(succ)
      fold!(node, succ, succ.tag, dic: 2)
    when .adverb?
      node = fold!(node, succ, succ.tag, dic: 6)
    when .space?
      return node unless node.key = "最"
      return fold!(node, succ, succ.tag, dic: 7, flip: true)
    when .preposes?
      succ = fold_preposes!(succ)
      fold!(node, succ, succ.tag, dic: 2)
    else
      case node
      when .vead?
        fold_verbs!(cast_verb!(node))
      when .ajad?
        fold_adjts!(cast_adjt!(node))
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
end
