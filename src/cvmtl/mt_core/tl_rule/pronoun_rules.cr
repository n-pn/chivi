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
      fold_swap!(node, succ, PosTag::DefnPhrase, dic: 4)
    when .ptitle?
      return node unless should_not_combine_pro_per?(node.prev?, succ.succ?)
      fold_swap!(node, succ, succ.tag, dic: 4)
      # when .names?
      #   succ = fold_noun!(succ)
      #   return node unless succ.names?

      #   # TODO: add pseudo node
      #   node.val = "của #{node.val}"
      #   fold_swap!(node, succ, succ.tag, dic: 4)
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
    when node.pro_zhe?, .pro_ji? then succ = heal_quanti!(succ)
    when .pro_na1?
      succ = heal_quanti!(succ)
    end

    if succ && succ.quantis?
      node = fold!(node, succ, PosTag::ProDem, dic: 4)
    end

    if succ = node.succ?
      succ = scan_noun!(succ)
      return fold_pro_dem_noun!(node, succ) if succ.nouns?
    end

    case node.tag
    when .pro_zhe? then node.set!("cái này", PosTag::Conjunct)
    when .pro_na1? then node.set!("vậy", PosTag::Conjunct)
    else                node
    end
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
    node.tag = PosTag::NounPhrase
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

      fold!(prev, tail, PosTag::NounPhrase, dic: 3)
    when .ends_with?("个")
      fold!(prev, node, node.tag, dic: 3)
    when .starts_with?("各")
      fold!(prev, node, node.tag, dic: 3)
    when .starts_with?("这"), .starts_with?("那")
      head, tail = clean_pro_per!(prev)
      node.set_succ!(tail)
      fold!(prev, tail, node.tag, dic: 3)
    else
      fold_swap!(prev, node, node.tag, dic: 3)
    end
  end

  def clean_pro_per!(node : MtNode) : Tuple(MtNode, MtNode)
    key = node.key[0].to_s
    val = key == "这" ? "này" : "kia"

    tail = MtNode.new(key, val, PosTag::ProZhe, 1, node.idx)

    node.key = node.key[1..]
    node.val = node.key == "些" ? "những" : node.val.sub(" " + val, "")

    node.tag = PosTag::Qtnoun
    node.idx += 1

    {node, tail}
  end
end
