module CV::TlRule
  def is_linking_verb?(node : MtNode, succ : MtNode?) : Bool
    return true if node.vmodals?

    case node.key[-1]?
    when '来', '去', '到', '有', '上', '着', '想'
      true
    when '了', '过'
      {"就", "才", "再"}.includes?(succ.try(&.key))
    else
      # TODO: check with node.verb_object?
      succ.try(&.key.== "不") || false
    end
  end
end
