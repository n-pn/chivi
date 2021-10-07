module CV::TlRule
  def fold_verbs!(node : MtNode, succ = node.succ?, prev : MtNode? = nil)
    if end_sentence?(succ)
      node.val = "thật có lỗi" if node.key == "对不起"
      node.tag = PosTag::Vform
      return node
    end

    while node.verbs?
      break unless succ = node.succ?
      case succ
      when .ahao?
        node.fold!(succ, "#{node.val} tốt")
      when .ule?
        val = keep_ule?(node, succ) ? "#{node.val} rồi" : node.val
        node.fold!(succ, val)
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
        break unless nquant_is_complement?(node)
        node.val = node.val.sub("bả", "phát") if node.key.ends_with?("把")
        node.tag = PosTag::Vform
        node.fold!(dic: 6)
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
    return true if !succ || end_sentence?(succ)
    prev.key == succ.key && node.key == succ.succ?(&.key)
  end

  def fold_left_verb!(node : MtNode, prev = node.prev?)
    return node unless prev
    prev.tag = node.tag

    case prev.key
    when "最"
      prev.fold!(node, "#{node.val} #{prev.val}")
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
      return prev.fold_many!(node, succ)
    end

    prev.dic = 7
    uzhe_val = guess_uzhe_val(prev, node)
    prev.fold!(node, uzhe_val.empty? ? prev.val : "#{uzhe_val} #{prev.val}")
  end

  def guess_uzhe_val(prev : MtNode, node : MtNode)
    return "" if !(prev_2 = prev.prev?) || prev_2.adv_mei? || prev_2.verb?
    return "có" if prev_2.tag.place?

    # handle duplicate word
    case prev_2.key
    when "正", "正在", "在" then ""
    else                     "đang"
    end
  end
end
