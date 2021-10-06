module CV::TlRule
  def fold_adjts!(node : MtNode, succ = node.succ?, prev = node.prev?) : MtNode
    while node.adjts?
      break unless succ = node.succ?

      case succ.tag
      when .adjt?, .amorp?
        node.val = "thật" if node.tag.ahao?
        node.tag = PosTag::Adjt
        node.fold!(succ)
      when .noun?
        return node unless node.key.size == 1 # or special case
        succ = fold_noun!(succ)
        node.tag = PosTag::Nform
        return node.fold!(succ, val: "#{succ.val} #{node.val}", dic: 7)
      when .suf_nouns?
        return fold_suf_noun!(node, succ)
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

  def fold_adj_adv!(adj : MtNode, adv = adj.prev?)
    return adj unless adv
    adv.tag = PosTag::Aform

    case adv.key
    when "最"
      return adv.fold!(adj, "#{adj.val} nhất")
    when "挺"
      adv.val = "rất"
    end

    adv.fold!(adj)
  end
end
