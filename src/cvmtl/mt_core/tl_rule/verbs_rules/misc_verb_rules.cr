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

  def find_verb_after(right : MtNode)
    while right = right.succ?
      # puts ["find_verb", right]
      return right if right.verbs? || right.preposes?
      return nil unless right.adverbs? || right.comma? # || right.conjunct?
    end
  end

  def scan_verb!(node : MtNode)
    case node
    when .adverbs?  then fold_adverbs!(node)
    when .preposes? then fold_preposes!(node)
    else                 fold_verbs!(node)
    end
  end
end
