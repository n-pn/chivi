module CV::TlRule
  def fold_pronouns!(pronoun : MtNode, succ = pronoun.succ?) : MtNode
    return pronoun unless succ

    case pronoun.tag
    when .pro_per?  then fold_pro_per!(pronoun, succ)
    when .pro_dems? then fold_pro_dems!(pronoun, succ)
    else                 pronoun
    end
  end

  def fold_pro_per!(node : MtNode, succ : MtNode) : MtNode
    case succ.tag
    when .space?
      fold_swap!(node, succ, PosTag::Place, dic: 4)
    when .place?
      fold_swap!(node, succ, PosTag::Dphrase, dic: 4)
    when .ptitle?
      return node unless should_not_combine_pro_per?(node.prev?, succ.succ?)
      fold_swap!(node, succ, succ.tag, dic: 4)
    when .names?
      succ = fold_noun!(succ)
      return node unless succ.names?

      # TODO: add pseudo node
      node.val = "của #{node.val}"
      fold_swap!(node, succ, succ.tag, dic: 4)
    when .penum?, .concoord?
      return node unless (succ_2 = succ.succ?) && nouns_can_group?(node, succ_2)
      succ = heal_concoord!(succ) if succ.concoord?
      fold!(node, succ_2, tag: succ_2.tag, dic: 3)
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
    case node
    when node.pro_zhe?, .pro_ji?
      succ = heal_quanti!(succ)
    when .pro_na1?
      if succ.pro_per?
        return node.set!("vậy", PosTag::Conjunct)
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
    prev.val = prev.val.sub("cái", "").strip if prev.key.ends_with?("个")

    case prev.key
    when "各"
      prev.val = "các"
      fold!(prev, node, node.tag, dic: 2)
    when "这", "那", "这个", "那个"
      fold_swap!(prev, node, node.tag, dic: 2)
    when "这样"
      prev.val = "như vậy"
      fold_swap!(prev, node, node.tag, dic: 2)
    when "那样"
      prev.val = "như thế"
      fold_swap!(prev, node, node.tag, dic: 2)
    when "任何"
      prev.val = "bất kỳ"
      fold!(prev, node)
    when "其他"
      tail = MtNode.new("他", "khác", PosTag::ProPer, 1, prev.idx + 1)
      tail.fix_succ!(node.succ?)
      node.fix_succ!(tail)

      prev.key = "其"
      prev.val = "các"

      fold!(prev, tail, PosTag::Nphrase, dic: 3)
    when .ends_with?("个")
      fold!(prev, node, node.tag, dic: 3)
    when .starts_with?("各")
      fold!(prev, node, node.tag, dic: 3)
    when .starts_with?("这")
      tail = MtNode.new("这", "này", PosTag::ProZhe, 1, prev.idx)
      tail.fix_succ!(node.succ?)
      node.fix_succ!(tail)

      prev.key = prev.key.sub("这", "")
      prev.val = prev.val.sub(" này", "")
      prev.tag = PosTag::Qtnoun
      prev.idx += 1

      fold!(prev, tail, node.tag, dic: 3)
    when .starts_with?("那")
      tail = MtNode.new("那", "kia", PosTag::ProZhe, 1, prev.idx)
      tail.fix_succ!(node.succ?)
      node.fix_succ!(tail)

      prev.key = prev.key.sub("那", "")
      prev.val = prev.val.sub(" kia", "")
      prev.tag = PosTag::Qtnoun
      prev.idx += 1

      fold!(prev, tail, node.tag, dic: 3)
    else
      fold_swap!(prev, node, node.tag, dic: 3)
    end
  end
end
