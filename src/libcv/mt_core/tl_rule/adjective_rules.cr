module CV::TlRule
  def fold_adjts!(node : MtNode, succ = node.succ?, prev = node.prev?) : MtNode
    while node.adjts?
      break unless succ = node.succ?

      case succ.tag
      when .adjt?, .amorp?
        node.val = "thật" if node.tag.ahao?
        node = fold!(node, succ, node.tag)
      when .noun?
        return node unless node.key.size == 1 # or special case
        succ = fold_noun!(succ)
        node.set_prev(succ)
        return fold!(succ, node, PosTag::Nphrase, dic: 3)
      when .verb?
        break unless node.key.size == 1
        succ = fold_verbs!(succ)

        if succ.verbs? && node.tag.ahao?
          node.tag = PosTag::Verb
          return node.fold!(succ, "thật #{succ.val}")
        end

        node = fold_adj_adv!(node, prev) if prev
        node.tag = PosTag::Vphrase
        return node.fold!(succ, "#{succ.val} #{node.val}")
      when .ude2?
        break unless succ_2 = succ.succ?
        break unless succ_2.verb? || succ_2.veno?

        succ_2 = fold_verbs!(succ_2)
        node = fold_adj_adv!(node, prev) if prev

        node.val = "#{node.val} mà #{succ_2.val}"
        node.dic = 7
        node.tag = PosTag::Vphrase
        return node.fold_many!(succ, succ_2)
      when .suf_nouns?
        return fold_suf_noun!(node, succ)
      when .uzhi?
        node = fold_adj_adv!(node, prev) if prev
        return node = fold_uzhi!(succ, node)
      when .suf_verbs?
        return fold_suf_verb!(node, succ)
      when .penum?, .concoord?
        break unless (succ_2 = succ.succ?) && can_combine_adjt?(node, succ_2)
        heal_concoord!(succ) if succ.concoord?
        node = fold!(node, succ, PosTag::Aphrase, 3)
      when .adv_bu?
        break unless (succ_2 = succ.succ?)

        if prev && prev.adv_bu?
          prev.tag = PosTag::Aphrase
          prev.dic = 6
          prev.val = "không #{node.val} không #{node.val}"
          return prev.fold_many!(node, succ, succ_2)
        elsif succ_2.key == node.key
          node.tag = PosTag::Aphrase
          node.dic = 6
          node.val = "#{node.val} hay không"
          node.fold_many!(node, succ, succ_2)
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
    # TODO: combine with nouns
    node.fold_left!(nega)
  end

  def fold_adj_adv!(node : MtNode, prev = node.prev?)
    return node unless prev

    case prev.key
    when "最", "那么", "这么", "非常"
      head, tail = swap!(prev, node)
      fold!(head, tail, PosTag::Adjt, dic: 2)
    when "不太"
      prev.fold!(node, "không #{node.val} lắm")
    else
      prev.val = "rất" if prev.key == "挺"
      fold!(prev, node, PosTag::Aphrase, dic: 2)
    end
  end
end
