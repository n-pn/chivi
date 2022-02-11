module CV::TlRule
  # ameba:disable Metrics/CyclomaticComplexity
  def fold_vmodals!(node : MtNode, succ = node.succ?, nega : MtNode? = nil) : MtNode
    return node.set!(PosTag::Noun) if vmodal_is_noun?(node)
    succ.tag = PosTag::Verb if succ && (succ.veno? || succ.vead?)

    # puts [node, succ, nega]

    case node
    when .vm_hui? then node = heal_vm_hui!(node, succ, nega)
    when .vm_xiang?
      return fold_verbs!(node.set!(PosTag::Verb)) if succ.try(&.adv_bu?)
      node = heal_vm_xiang!(node, succ, nega)
      return fold_verbs!(node) if node.verb?
    else
      node.tag = PosTag::Noun if vmodal_is_noun?(node)
      node = fold!(nega, node, node.tag, dic: 6) if nega
    end

    case succ
    when .nil? then node
    when .preposes?
      return node if succ.pre_bi3?
      node = fold!(node, succ, succ.tag, dic: 6)
      fold_preposes!(node)
    when .adverbs?
      succ = fold_adverbs!(succ)
      succ.verb? ? fold!(node, succ, succ.tag, dic: 6) : node
    when .verbs?
      verb = fold!(node, succ, succ.tag, dic: 6)
      fold_verbs!(verb)
    when .nouns?
      # return node unless node.vm_neng?
      fold_verb_object!(node, succ)
    else
      node
    end
  end

  def vmodal_is_noun?(node : MtNode)
    return false unless node.key == "可能"
    return true unless succ = node.succ?
    succ.ends? || succ.v_shi? || succ.v_you?
  end

  def heal_vm_hui!(node : MtNode, succ = node.succ?, prev = node.prev?) : MtNode
    if vmhui_before_skill?(prev, succ)
      node.val = "biết"
      flip = false
    else
      node.val = "sẽ"
      flip = prev.try(&.adv_bu?)
    end

    prev ? fold!(prev, node, node.tag, dic: 6, flip: flip) : node
  end

  private def vmhui_before_skill?(prev : MtNode?, succ : MtNode?) : Bool
    return true if {"只", "还"}.includes?(prev.try(&.key))

    case succ
    when .nil?, .ends?, .nouns?, .ude1?, .ule?
      true
    when .preposes? then false
    when .verb_object?
      MtDict.has_key?(:v_group, succ.key)
    else
      if succ.key == "生气"
        succ.val = "tức giận"
        return false
      end

      {"都", "也", "太"}.includes?(prev.try(&.key))
    end
  end

  # ameba:disable Metrics/CyclomaticComplexity
  def heal_vm_xiang!(node : MtNode, succ = node.succ?, nega : MtNode? = nil) : MtNode
    case succ
    when .nil? # do nothing
    when .verbs?, .preposes?
      node.val = "muốn"
    when .human?
      if has_verb_after?(succ)
        node.set!("muốn")
      else
        node.set!("nhớ", PosTag::Verb)
      end
    when .adverbs?
      if succ.key == "也" && !succ.succ?(&.maybe_verb?)
        node.val = "nhớ"
      elsif succ.key == "越"
        node.val = "nghĩ"
      else
        node.val = "muốn"
      end
    else
      if succ.vdirs? || MtDict.fix_vcompl(succ)
        node.set!("nhớ") if succ.succ?(&.human?)
      end
    end

    nega ? fold!(nega, node, node.tag, dic: 2) : node
  end
end
