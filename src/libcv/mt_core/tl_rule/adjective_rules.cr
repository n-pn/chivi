module CV::TlRule
  def fold_adjts!(node : MtNode, succ = node.succ?, prev = node.prev?) : MtNode
    while node.adjts?
      break unless succ = node.succ?

      case succ.tag
      when .adjt?, .amorp?
        node.val = "thật" if node.tag.ahao?
        node = fold!(node, succ, PosTag::Adjt)
      when .noun?
        break unless node.key.size == 1 && !prev # or special case

        head, tail = swap!(node, succ)
        return fold!(head, tail, PosTag::Nphrase, dic: 4)
      when .verb?
        break unless node.key.size == 1 && !prev
        succ = fold_verbs!(succ)

        if succ.verbs? && node.tag.ahao?
          node.val = "thật"
          return fold!(node, succ, PosTag::Verb, dic: 4)
        end

        head, tail = swap!(node, succ)
        return fold!(head, tail, PosTag::Vphrase, dic: 4)
      when .ude2?
        break unless succ_2 = succ.succ?
        break unless succ_2.verb? || succ_2.veno?

        succ_2 = fold_verbs!(succ_2)
        node = fold_adj_adv!(node, prev)

        succ.val = "mà"
        return fold!(node, succ_2, PosTag::Vphrase, 4)
      when .uzhi?
        node = fold_adj_adv!(node, prev)
        return fold_uzhi!(succ, node)
      when .suf_nouns?
        node = fold_adj_adv!(node, prev)
        return fold_suf_noun!(node, succ)
      when .suf_verbs?
        node = fold_adj_adv!(node, prev)
        return fold_suf_verb!(node, succ)
      when .penum?, .concoord?
        break unless (succ_2 = succ.succ?) && can_combine_adjt?(node, succ_2)
        heal_concoord!(succ) if succ.concoord?
        node = fold!(node, succ, PosTag::Aphrase, 4)
      when .adv_bu?
        break unless (succ_2 = succ.succ?)

        if prev && prev.adv_bu?
          return fold!(prev, succ_2, PosTag::Aphrase, 5)
        elsif succ_2.key == node.key
          node = fold_adj_adv!(node, prev)
          succ.val = "hay"
          succ_2.val = "không"
          return fold!(node, succ_2, PosTag::Aphrase, 5)
        end

        break
      else
        break
      end

      break if succ == node.succ?
    end

    # TODO: combine with nouns
    fold_adj_adv!(node, prev)
  end

  def fold_modifier!(node : MtNode, succ = node.succ?, nega : MtNode? = nil)
    if nega
      head, tail = swap!(node, nega)
      node = fold!(head, tail, node.tag, dic: 3)
    else
      # TODO: combine with nouns
      node
    end
  end

  def fold_adj_adv!(node : MtNode, prev = node.prev?)
    return node unless prev

    case prev.key
    when "最", "那么", "这么", "非常"
      head, tail = swap!(prev, node)
      fold!(head, tail, PosTag::Adjt, dic: 4)
    when "不太"
      head = MtNode.new("不", "không", PosTag::AdvBu, 1, prev.idx)
      tail = MtNode.new("太", "lắm", PosTag::Adverb, 1, prev.idx + 1)

      head.fix_prev!(prev.prev?)
      head.fix_succ!(node)
      tail.fix_succ!(node.succ?)
      tail.fix_prev!(node)
      fold!(head, tail, PosTag::Aphrase, dic: 4)
    else
      prev.val = "rất" if prev.key == "挺"
      fold!(prev, node, PosTag::Aphrase, dic: 4)
    end
  end
end
