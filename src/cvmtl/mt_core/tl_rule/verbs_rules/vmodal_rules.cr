module CV::TlRule
  def heal_vmodal!(node : MtNode, succ = node.succ?, nega : MtNode? = nil) : MtNode
    succ.tag = PosTag::Verb if succ && (succ.veno? || succ.vead?)

    # puts [node, succ, nega]

    case node
    when .vm_hui?   then node = heal_vm_hui!(node, succ, nega)
    when .vm_xiang? then node = heal_vm_xiang!(node, succ, nega)
    else
      if vmodal_is_noun?(node)
        node.tag = PosTag::Noun
      end

      node = fold!(nega, node, node.tag, dic: 6) if nega
    end

    return node unless succ && succ.verb?

    succ = fold_verbs!(succ)
    succ.set!(PosTag::Verb) if succ.v_you?
    fold!(node, succ, succ.tag, dic: 6)
  end

  def vmodal_is_noun?(node : MtNode)
    return false unless node.key == "可能"
    return true unless succ = node.succ?
    succ.ends? || succ.v_shi? || succ.v_you?
  end

  def heal_vm_hui!(node : MtNode, succ = node.succ?, prev = node.prev?) : MtNode
    if is_learnable_skill?(succ)
      node.val = "biết"
      flip = false
    else
      node.val = "sẽ"
      flip = prev.try(&.adv_bu?)
    end

    prev ? fold!(prev, node, node.tag, dic: 6, flip: flip) : node
  end

  private def is_learnable_skill?(node : MtNode?) : Bool
    return true unless node

    case node.tag
    when .exmark?, .qsmark?, .nouns? then true
    when .adverbs?                   then false
    when .verb?, .verb_object?
      MtDict::VERBS_SEPERATED.has_key?(node.key)
    else
      case node.prev?(&.key)
      when "都", "也" then true
      else               false
      end
    end
  end

  def heal_vm_xiang!(node : MtNode, succ = node.succ?, nega : MtNode? = nil) : MtNode
    if has_verb_after?(node)
      node.val = "muốn"
    elsif succ && succ.human?
      if has_verb_after?(succ)
        node.set!("muốn")
      else
        node.set!("nhớ", PosTag::Verb)
      end
    end

    nega ? fold!(nega, node, node.tag, dic: 2) : node
  end
end
