module CV::TlRule
  def fold_verbs!(node : MtNode, succ = node.succ?, prev : MtNode? = nil)
    while node.verbs?
      break unless succ = node.succ?

      case succ
      when .ahao?
        node.fold!(succ, "#{node.val} tốt")
      when .ule?
        val = keep_ule?(node, succ) ? "#{node.val} rồi" : node.val
        node.fold!(succ, val)

        # TODO: fold nunbers
        if (succ_2 = succ.succ?) && succ_2.nquant?
          node.tag = PosTag::Vform
          node.fold!(succ, dic: 6)
          break
        end
      when .ude2?
        break unless succ_2 = succ.succ?
        break unless succ_2.verb? || succ_2.veno?

        succ_2 = fold_verbs!(succ_2)
        node = fold_left_verb!(node, prev) if prev

        node.val = "#{succ_2.val} một cách #{node.val}"
        node.dic = 7
        node.tag = PosTag::Vform
        return node.fold_many!(succ, succ_2)
      when .uguo?
        node.fold!(succ, "#{node.val} qua")
      when .uzhe?
        node = fold_verb_uzhe!(node, succ)
        break if node.vform?
      when .nquant?
        # TODO: fold nunbers
        unless succ.succ?(&.nouns?)
          node.tag = PosTag::Vform
          node.fold!(succ, dic: 6)
        end

        break
      when .suf_nouns?
        node = fold_suf_noun!(node, succ)
        break
      when .suffix_shi?
        node = fold_suf_shi!(node, succ)
        break
      else
        break
      end
    end

    fold_left_verb!(node, prev)
  end

  def keep_ule?(prev : MtNode, node : MtNode, succ = node.succ?) : Bool
    return true unless succ
    succ.ends? || succ.succ?(&.ule?) || false
  end

  def fold_left_verb!(node : MtNode, prev = node.prev?)
    return node unless prev
    prev.tag = node.tag

    case prev.key
    when "最", "那么", "这么", "非常"
      prev.fold!(node, "#{node.val} #{prev.val}")
    when "不太"
      prev.fold!(node, "không #{node.val} lắm")
    else
      prev.fold!(node)
    end
  end

  def fold_verb_uzhe!(prev : MtNode, node : MtNode, succ = node.succ?) : MtNode
    if succ && succ.verbs?
      succ = fold_verbs!(succ)
      prev.val = "#{prev.val} #{succ.val}"

      prev.tag = PosTag::Vform
      prev.dic = 6

      prev.fold_many!(node, succ)
    else
      prev.fold!(node, prev.val, dic: 6)
    end
  end
end
