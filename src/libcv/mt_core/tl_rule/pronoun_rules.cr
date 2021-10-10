module CV::TlRule
  def fold_pronouns!(node : MtNode, succ = node.succ?) : MtNode
    return node unless succ

    case node.tag
    when .propers? then fold_propers!(node, succ)
    else                node
    end
  end

  def fold_propers!(node : MtNode, succ : MtNode) : MtNode
    case succ.tag
    when .ptitle?
      return node unless should_not_combine_propers?(node.prev?, succ.succ?)
      node.fold!(succ, "#{succ.val} #{node.val}")
    when .names?
      succ = fold_noun!(succ)
      succ.names? ? node.fold!(succ, "#{succ.val} của #{node.val}") : node
    else
      # TODO: handle special cases
      node
    end
  end

  def fold_propers!(node : MtNode, succ = node.succ?) : MtNode
    succ ? fold_propers!(node, succ) : node
  end

  private def should_not_combine_propers?(prev : MtNode?, succ : MtNode?)
    return false unless prev && succ
    return false unless prev.verbs?

    succ.verbs? || succ.adverbs? && succ.succ?(&.verbs?)
  end

  def fold_prodeics?(node : MtNode, succ : MtNode) : MtNode
    if node.pro_zhe? || node.pro_na1?
      succ = heal_quanti!(succ)
      return node unless succ.quanti?
    end

    node
  end
end
