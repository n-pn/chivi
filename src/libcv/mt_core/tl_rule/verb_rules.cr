module CV::TlRule
  def heal_vhui!(node : MtNode, succ = node.succ?) : MtNode
    return node unless succ

    if succ.nouns? || is_skill?(succ)
      node.val = node.key[0]? == '不' ? "không biết" : "biết"
    end

    node
  end

  def is_skill?(succ : MtNode) : Bool
    case succ.key[0]?
    when '打', '说', '做' then true
    else
      {"跳舞", "做饭", "开车", "游泳"}.includes?(succ.key)
    end
  end

  def heal_vxiang!(node : MtNode, succ = node.succ?) : MtNode
    return node unless succ

    if succ_is_verb?(succ)
      node.val = node.val.sub("nghĩ", "muốn")
    elsif succ.nouns? || succ.pronouns?
      unless succ_is_verb?(succ.succ?)
        node.val = node.val.sub("nghĩ", "nhớ")
      end
    end

    node
  end

  def succ_is_verb?(node : MtNode) : Bool
    return true if node.verbs?
    node.adverb? && node.succ?(&.verbs?) || false
  end

  def succ_is_verb?(node : Nil) : Nil
    false
  end
end
