module CV::TlRule
  def heal_vhui!(node : MtNode) : MtNode
    return node unless succ = node.succ?

    if succ.nouns? || is_skill?(succ)
      node.val = node.key[0]? == '不' ? "không biết" : "biết"
    end

    node
  end

  def is_skill?(succ : MtNode) : Bool
    case succ.key[0]?
    when '打', '说', '做' then true
    else
      {"跳舞", "做饭", "开车", "游泳"}.includes?(key)
    end
  end
end
