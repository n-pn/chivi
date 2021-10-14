module CV::TlRule
  def fold_verbs!(node : MtNode, succ = node.succ?, prev : MtNode? = nil)
    while node.verbs?
      break unless succ = node.succ?

      case succ
      when .uzhi?
        node = fold_left_verb!(node, prev) if prev
        return fold_uzhi!(succ, node)
      when .auxils?
        node = fold_left_verb!(node, prev) if prev
        node = fold_verb_auxils!(node, succ)
        break if node.vphrase? || succ == node.succ?
      when .vcompls?
        node = fold_left_verb!(node, prev) if prev
        node = fold_verb_vcompls!(node, succ)
      when .adv_bu?
        break unless (succ_2 = succ.succ?) && succ_2.key == node.key

        # TODO: combine with object
        node.dic = 7
        node.val = "#{node.val} hay không"
        node = node.fold_many!(succ, succ_2)
      when .nquants?
        succ = fold_number!(succ)

        if succ.nquant? && !succ.succ?(&.nouns?)
          node.tag = PosTag::Vphrase
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

  def fold_verb_auxils!(node : MtNode, succ : MtNode) : MtNode
    case succ.tag
    when .ule?
      val = keep_ule?(node, succ) ? "#{node.val} rồi" : node.val
      node.fold!(succ, val)

      return node unless (succ = succ.succ?) && succ.nquants?

      succ = fold_number!(succ) if succ.numbers?
      return node unless succ.nquant?

      node.tag = PosTag::Vphrase
      node.fold!(succ, dic: 6)
    when .ude2?
      return node unless succ_2 = succ.succ?
      return node unless succ_2.verb? || succ_2.veno?

      succ_2 = fold_verbs!(succ_2)

      node.val = "#{succ_2.val} một cách #{node.val}"
      node.dic = 7
      node.tag = PosTag::Verb
      node.fold_many!(succ, succ_2)
    when .ude3?
      fold_verb_ude3!(node, succ)
    when .uguo?
      node.fold!(succ, "#{node.val} qua")
    when .uzhe?
      fold_verb_uzhe!(node, succ)
    when .uguo?
      node.fold!(succ, "#{node.val} qua")
    else
      node
    end
  end

  def fold_verb_vcompls!(node : MtNode, succ : MtNode)
    node.tag == PosTag::Vphrase

    case succ.tag
    when .ahao?
      node.fold!(succ, "#{node.val} tốt")
    when .vshang?, .vxia?
      node.fold!(succ, "#{node.val} #{succ.val}")
    when .pre_dui?
      node.fold!(succ, "#{node.val} đúng")
    when .vdir?
      case succ.key
      when "起"  then val = "lên"
      when "进"  then val = "vào"
      when "来"  then val = "tới"
      when "过去" then val = "qua"
      when "下去" then val = "tiếp"
      when "下来" then val = "lại"
      when "起来" then val = "lên"
      else           val = succ.val
      end

      node.fold!(succ, "#{node.val} #{val}")
    else
      node.fold!(succ, "#{node.val} #{succ.val}")
    end
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

      prev.tag = PosTag::Verb
      prev.dic = 6

      prev.fold_many!(node, succ)
    else
      prev.fold!(node, prev.val, dic: 6)
    end
  end
end
