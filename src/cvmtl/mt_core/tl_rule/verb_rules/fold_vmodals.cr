module CV::TlRule
  def heal_vmodal!(node : MtNode, succ = node.succ?, nega : MtNode? = nil) : MtNode
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
    case succ
    when .nil?, .exmark?, .qsmark?, .nouns?
      true
    when .verb_object?
      MtDict::VERBS_SEPERATED.has_key?(succ.key)
    else
      {"都", "也", "只"}.includes?(prev.try(&.key))
    end
  end

  def heal_vm_xiang!(node : MtNode, succ = node.succ?, nega : MtNode? = nil) : MtNode
    if succ
      if succ.vdirs? || (val = MtDict::VERB_COMPLEMENT.get(succ.key))
        node.set!("nhớ") if succ.succ?(&.human?)
        succ.set!(val || succ.val, PosTag::Verb)
      elsif succ.key != "也" && has_verb_after?(node)
        node.val = "muốn"
      elsif succ.human?
        if has_verb_after?(succ)
          node.set!("muốn")
        else
          node.set!("nhớ", PosTag::Verb)
        end
      end
    end

    nega ? fold!(nega, node, node.tag, dic: 2) : node
  end
end