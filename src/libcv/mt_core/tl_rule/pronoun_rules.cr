module CV::TlRule
  def fold_pronouns!(node : MtNode, succ = node.succ?) : MtNode
    return node unless succ

    case node.tag
    when .pro_per?  then fold_pro_per!(node, succ)
    when .pro_dems? then fold_pro_dems!(node, succ)
    else                 node
    end
  end

  def fold_pro_per!(node : MtNode, succ : MtNode) : MtNode
    case succ.tag
    when .space?
      fold_swap!(node, succ, succ.tag, 7)
    when .ptitle?
      return node unless should_not_combine_pro_per?(node.prev?, succ.succ?)
      fold_swap!(node, succ, succ.tag, 7)
    when .names?
      succ = fold_noun!(succ)
      return node unless succ.names?

      # TODO: add pseudo node
      node.val = "của #{node.val}"
      fold_swap!(node, succ, succ.tag, 8)
    else
      # TODO: handle special cases
      node
    end
  end

  def fold_pro_per!(node : MtNode, succ = node.succ?) : MtNode
    succ ? fold_pro_per!(node, succ) : node
  end

  private def should_not_combine_pro_per?(prev : MtNode?, succ : MtNode?)
    return false unless prev && succ
    return false unless prev.verbs?

    succ.verbs? || succ.adverbs? && succ.succ?(&.verbs?)
  end

  def fold_pro_dems!(node : MtNode, succ : MtNode) : MtNode
    if node.pro_zhe?
      succ = heal_quanti!(succ)
    elsif node.pro_na1?
      if succ.pro_per?
        return node.heal!("vậy", PosTag::Conjunct)
      end

      succ = heal_quanti!(succ)
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

  def fold_pro_dem_noun!(prev : MtNode, node : MtNode)
    node.tag = PosTag::Nphrase

    case prev.key
    when "各"
      prev.val = "các"
      fold!(prev, node, node.tag, 2)
    when "这", "这个"
      fold_swap!(prev, node, node.tag, 2)
    when "那", "那个"
      prev.val = "kia"
      fold_swap!(prev, node, node.tag, 2)
    when "这样"
      prev.val = "như vậy"
      fold_swap!(prev, node, node.tag, 2)
    when "那样"
      prev.val = "như thế"
      fold_swap!(prev, node, node.tag, 2)
    when "任何"
      prev.val = "bất kỳ"
      fold!(prev, node)
    when "其他"
      tail = MtNode.new("他", "khác", PosTag::ProPer, 1, prev.idx + 1)
      tail.fix_succ!(node.succ?)
      node.fix_succ!(tail)

      prev.key = "其"
      prev.val = "các"

      fold!(prev, tail, PosTag::Nphrase, 4)
    when .ends_with?("个")
      prev.val = prev.val.sub("cái", "").strip
      fold!(prev, node, node.tag, 4)
    when .starts_with?("各")
      fold!(prev, node, node.tag, 4)
    when .starts_with?("这")
      tail = MtNode.new("这", "này", PosTag::ProZhe, 1, prev.idx)
      tail.fix_succ!(node.succ?)
      node.fix_succ!(tail)

      prev.key = prev.key.sub("这", "")
      prev.val = prev.val.sub(" này", "")
      prev.tag = PosTag::Quanti
      prev.idx += 1

      fold!(prev, tail, node.tag, 4)
    when .starts_with?("那")
      tail = MtNode.new("那", "kia", PosTag::ProZhe, 1, prev.idx)
      tail.fix_succ!(node.succ?)
      node.fix_succ!(tail)

      prev.key = prev.key.sub("那", "")
      prev.val = prev.val.sub(" kia", "")
      prev.tag = PosTag::Quanti
      prev.idx += 1

      fold!(prev, tail, node.tag, 4)
    else
      fold_swap!(prev, node)
    end
  end
end
