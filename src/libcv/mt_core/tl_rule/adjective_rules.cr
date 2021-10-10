module CV::TlRule
  def fold_adjts!(node : MtNode, succ = node.succ?, prev = node.prev?) : MtNode
    while node.adjts?
      break unless succ = node.succ?

      case succ.tag
      when .adjt?, .amorp?
        node.val = "thật" if node.tag.ahao?
        node.tag = PosTag::Adjt
        node.fold!(succ)
      when .verb?
        break unless node.key.size == 1
        node.val = "thật" if node.tag.ahao?

        node = fold_adj_adv!(node, prev) if prev
        succ = fold_verbs!(succ)
        node.tag = PosTag::Vform
        return node.fold!(succ, "#{succ.val} #{node.val}")
      when .ude2?
        break unless succ_2 = succ.succ?
        break unless succ_2.verb? || succ_2.veno?

        succ_2 = fold_verbs!(succ_2)
        node = fold_adj_adv!(node, prev) if prev

        node.val = "#{succ_2.val} #{node.val}"
        node.dic = 8
        node.tag = PosTag::Vform
        return node.fold_many!(succ, succ_2)
      when .noun?
        return node unless node.key.size == 1 # or special case
        succ = fold_noun!(succ)
        node.tag = PosTag::Nform
        return node.fold!(succ, val: "#{succ.val} #{node.val}", dic: 7)
      when .suf_nouns?
        return fold_suf_noun!(node, succ)
      when .uzhi?
        node = fold_adj_adv!(node, prev) if prev
        return node = fold_uzhi!(succ, node)
      when .suf_verbs?
        return fold_suf_verb!(node, succ)
      when .concoord?
        break unless succ_2 = succ.succ?
        # TODO: change tag accordingly
        node = fold_concoord!(node, succ, succ_2, force: succ_2.adjts?)
        break if node.succ == succ
      when .penum?
        break unless succ_2 = succ.succ?
        # TODO: change tag accordingly
        node = fold_penum!(node, succ, succ_2, force: succ_2.adjts?)
        break if node.succ == succ
      else
        break
      end
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
    prev.tag = PosTag::Aform

    case prev.key
    when "最", "那么", "这么", "非常"
      prev.fold!(node, "#{node.val} #{prev.val}")
    when "不太"
      prev.fold!(node, "không #{node.val} lắm")
    else
      prev.val = "rất" if prev.key == "挺"
      prev.fold!(node)
    end
  end
end
