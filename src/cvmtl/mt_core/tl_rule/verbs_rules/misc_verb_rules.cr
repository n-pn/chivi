module CV::TlRule
  def is_linking_verb?(node : MtNode, succ : MtNode?) : Bool
    return true if node.vmodals?

    {"来", "去", "到", "有", "上", "着", "想"}.each do |char|
      return true if node.ends_with?(char)
    end

    return false unless succ
    return true if succ.starts_with?("不")

    {"了", "过"}.each do |char|
      return {"就", "才", "再"}.includes?(succ.key) if node.ends_with?(char)
    end

    false
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
