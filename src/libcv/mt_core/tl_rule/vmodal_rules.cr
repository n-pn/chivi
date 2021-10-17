module CV::TlRule
  def heal_vmodal!(node : MtNode, succ = node.succ?, nega : MtNode? = nil) : MtNode
    succ.tag = PosTag::Verb if succ && (succ.veno? || succ.vead?)

    case node
    when .vm_hui?   then node = heal_vm_hui!(node, succ, nega)
    when .vm_xiang? then node = heal_vm_xiang!(node, succ, nega)
    else
      if vmodal_is_noun?(node, "可能")
        node.tag = PosTag::Noun
        return fold_noun_left!(node)
      end

      node = fold!(nega, node, node.tag, 6) if nega
    end

    succ && succ.verb? ? fold!(node, succ, succ.tag, 6) : node
  end

  def vmodal_is_noun?(node : MtNode, key : String)
    return false unless node.key == "可能"
    return true if !(succ = node.succ?) || succ.ends?

    # TODO: add more cases
    node.prev?(&.ude1?)
  end

  def heal_vm_hui!(node : MtNode, succ = node.succ?, prev = node.prev?) : MtNode
    nega = prev.try(&.adv_bu?)

    if is_skill_succ?(succ) || is_skill_prev?(prev.try(&.prev?))
      node.val = "biết"
      prev ? fold!(prev, node, node.tag, dic: 6) : node
    else
      node.val = "sẽ"
      prev ? fold_swap!(prev, node, node.tag, dic: 6) : node
    end
  end

  private def is_skill_succ?(succ : MtNode?) : Bool
    return true unless succ
    return true if succ.nouns? || succ.exmark? || succ.qsmark?

    case succ.key[0]?
    when '打', '说', '做' then true
    else
      {"跳舞", "做饭", "开车", "游泳"}.includes?(succ.key)
    end
  end

  private def is_skill_prev?(prev : MtNode?) : Bool
    return true unless prev

    case prev.key
    when "都", "也" then true
    else               false
    end
  end

  def heal_vm_xiang!(node : MtNode, succ = node.succ?, nega : MtNode? = nil) : MtNode
    if succ
      if succ_is_verb?(succ)
        node.val = "muốn"
      elsif succ.nouns? || succ.pronouns?
        unless succ_is_verb?(succ.succ?)
          node.val = "nhớ"
          node.tag = PosTag::Verb
        end
      end
    end

    nega ? fold!(nega, node, node.tag, 2) : node
  end

  private def succ_is_verb?(node : MtNode?) : Bool
    return false unless node

    node = fold_adverbs!(node) if node.adverbs?
    node.verbs?
  end
end
