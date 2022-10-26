module MT::TlRule
  # ameba:disable Metrics/CyclomaticComplexity
  def fold_vmodal!(node : MtNode, succ = node.succ?, nega : MtNode? = nil) : MtNode
    case node
    when .vm_hui?
      node = heal_vm_hui!(node, succ, nega)
    when .vm_xiang?
      return fold_verbs!(node.set!(PosTag::Verb)) if succ.try(&.adv_bu4?)
      node = heal_vm_xiang!(node, succ, nega)
      return fold_verbs!(node) if node.verb?
      # when .key?("要")
      # node.set!("phải") if succ.try(&.maybe_verb?)
    when .key_is?("可")
      if nega
        node.val = "thể"
        node = fold!(nega, node, node.tag)
      else
        node.val = "có thể" if succ.try(&.verbal?)
      end
    else
      node = fold!(nega, node, node.tag) if nega
    end

    case succ
    when .nil? then node
    when .preposes?
      return node if succ.prep_bi3?
      node = fold!(node, succ, succ.tag)
      fold_preposes!(node)
    when .advbial?
      succ = fold_adverbs!(succ)
      succ.verb? ? fold!(node, succ, succ.tag) : node
    when .verbal?
      verb = fold!(node, succ, succ.tag)
      fold_verbs!(verb)
    when .noun_words?
      # return node unless node.vm_neng?
      fold_verb_object!(node, succ)
    else
      node
    end
  end

  def heal_vm_hui!(node : MtNode, succ = node.succ?, prev = node.prev?) : MtNode
    if vmhui_before_skill?(prev, succ)
      node.val = "biết"
      flip = false
    else
      node.val = "sẽ"
      flip = prev.try(&.adv_bu4?)
    end

    prev ? fold!(prev, node, node.tag, flip: flip) : node
  end

  private def vmhui_before_skill?(prev : MtNode?, succ : MtNode?) : Bool
    return true if prev.try(&.key.in?({"只", "还", "都"}))

    case succ
    when .nil?, .boundary?, .noun_words?, .ptcl_dep?, .ptcl_le?
      true
    when .preposes?     then false
    when .vsep?, .vset? then true
    else
      case succ.key
      when "生气"
        succ.val = "tức giận"
        false
      when .starts_with?("做")
        true
      else
        {"都", "也", "太"}.includes?(prev.try(&.key))
      end
    end
  end

  # ameba:disable Metrics/CyclomaticComplexity
  def heal_vm_xiang!(node : MtNode, succ = node.succ?, nega : MtNode? = nil) : MtNode
    case succ
    when .nil? # do nothing
    when .v_shi?
      node.val = "nghĩ"
    when .verbal?, .preposes?
      node.val = "muốn"
    when .cap_human?
      if has_verb_after?(succ)
        node.set!("muốn")
      else
        node.set!("nhớ", PosTag::Verb)
      end
    when .advbial?
      if succ.key == "也" && !succ.succ?(&.maybe_verb?)
        node.val = "nhớ"
      elsif succ.key == "越"
        node.val = "nghĩ"
      else
        node.val = "muốn"
      end
    else
      if succ.maybe_cmpl?
        node.set!("nhớ") if succ.succ?(&.cap_human?)
      end
    end

    nega ? fold!(nega, node, node.tag) : node
  end
end
