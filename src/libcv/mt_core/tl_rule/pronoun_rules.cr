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
    when .space?
      head, tail = swap!(node, succ)
      fold!(head, tail, succ.tag, 7)
    when .ptitle?
      return node unless should_not_combine_propers?(node.prev?, succ.succ?)
      head, tail = swap!(node, succ)
      fold!(head, tail, succ.tag, 7)
    when .names?
      succ = fold_noun!(succ)
      return node unless succ.names?

      # TODO: add pseudo node
      node.val = "của #{node.val}"
      head, tail = swap!(node, succ)
      fold!(head, tail, succ.val, 8)
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
      node = swap_fold!(node, succ)
    end

    node
  end

  # FIX_PRONOUNS = {
  #   "这" => "này",
  #   "那" => "kia",
  #   "这个" => "kia",
  #   "那个" => "kia",
  #   "这样" => "như vậy",
  #   "那样" => "như thế",
  # }

  def fold_prodeic_noun!(prev : MtNode, node : MtNode)
    case prev.key
    when "各"
      prev.val = "các"
      fold!(prev, node, node.tag, 4)
    when "这", "这个"
      prev.val = "này"
      swap_fold!(prev, node, node.tag, 4)
    when "那", "那个"
      prev.val = "kia"
      swap_fold!(prev, node, node.tag, 4)
    when "这样"
      prev.val = "như vậy"
      swap_fold!(prev, node, node.tag, 4)
    when "那样"
      prev.val = "như thế"
      swap_fold!(prev, node, node.tag, 4)
    when "任何"
      prev.val = "bất kỳ"
      fold!(prev, node)
    when "其他" then node.fold_left!(prev, "các #{node.val} khác")
    when .ends_with?("个")
      prev.val = prev.val.sub("cái", "").strip
      fold!(prev, node, node.tag, 4)
    when .starts_with?("各")
      fold!(prev, node, node.tag, 4)
    when .starts_with?("这")
      val = prev.val.sub("này", "").strip
      prev.fold!(node, "#{val} #{node.val} này")
    when .starts_with?("那")
      val = prev.val.sub("kia", "").strip
      prev.fold!(node, "#{val} #{node.val} kia")
    else
      swap_fold!(prev, node)
    end
  end
end
