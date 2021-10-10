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
      node.fold!(succ, "#{succ.val} #{node.val}")
    end

    node
  end

  def fold_prodeic_noun!(prev : MtNode, node : MtNode)
    case prev.key
    when "这"  then node.fold_left!(prev, "#{node.val} này")
    when "那"  then node.fold_left!(prev, "#{node.val} kia")
    when "各"  then node.fold_left!(prev, "các #{node.val}")
    when "这样" then node.fold_left!(prev, "#{node.val} như vậy")
    when "那样" then node.fold_left!(prev, "#{node.val} như thế")
    when "这个" then node.fold_left!(prev, "#{node.val} này")
    when "那个" then node.fold_left!(prev, "#{node.val} kia")
    when .ends_with?("个")
      prev.val = prev.val.sub("cái", "").strip
      prev.fold!(node)
    when .starts_with?("各") then node = prev.fold!(node)
    when .starts_with?("这")
      val = prev.val.sub("này", "").strip
      prev.fold!(node, "#{val} #{node.val} này")
    when .starts_with?("那")
      val = prev.val.sub("kia", "").strip
      prev.fold!(node, "#{val} #{node.val} kia")
    when "其他" then node.fold_left!(prev, "các #{node.val} khác")
    when "任何" then node.fold_left!(prev, "bất kỳ #{node.val}")
    else           node.fold_left!(prev, "#{node.val} #{prev.val}")
    end
  end
end
