module CV::TlRule
  def fold_verbs!(node : MtNode, succ = node.succ?, prev : MtNode? = nil)
    node = fold_left_verb!(node, prev) if prev

    while node.verbs?
      break unless succ = node.succ?

      case succ
      when .uzhi?
        return fold_uzhi!(succ, node)
      when .auxils?
        node = fold_verb_auxils!(node, succ)
        break if node.vphrase? || succ == node.succ?
      when .vcompls?
        node = fold_verb_vcompls!(node, succ)
      when .adv_bu?
        break unless (succ_2 = succ.succ?) && succ_2.key == node.key
        succ.val = "hay"
        succ_2.val = "không"
        node = fold!(node, succ_2, dic: 2)
      when .nquants?
        succ = fold_number!(succ)

        if succ.nquant? && !succ.succ?(&.nouns?)
          node = fold!(node, succ, PosTag::Vphrase, 4)
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

      break if succ == node.succ?
    end

    node
  end

  def fold_verb_auxils!(node : MtNode, succ : MtNode) : MtNode
    case succ.tag
    when .ule?
      succ.val = "" unless keep_ule?(node, succ)
      node = fold!(node, succ, dic: 2)

      return node unless (succ = succ.succ?) && succ.nquants?
      succ = fold_number!(succ) if succ.numbers?
      return node unless succ.nquant?

      fold!(node, succ, PosTag::Vphrase, 6)
    when .ude2?
      return node unless (succ_2 = succ.succ?) && (succ_2.verb? || succ_2.veno?)
      succ_2 = fold_verbs!(succ_2)
      succ.val = "mà"
      # left, right = swap!(node, succ, succ_2)
      fold!(succ, succ_2, PosTag::Verb, 6)
    when .ude3?
      fold_verb_ude3!(node, succ)
    when .uzhe?
      fold_verb_uzhe!(node, succ)
    when .uguo?
      fold!(node, succ, dic: 1)
    else
      node
    end
  end

  def fold_verb_vcompls!(node : MtNode, succ : MtNode)
    case succ.tag
    when .ahao?
      # succ.val = "tốt"
      fold!(node, succ, dic: 3)
    when .vshang?, .vxia?
      fold!(node, succ, dic: 2)
    when .pre_dui?
      succ.val = "đúng"
      fold!(node, succ, dic: 2)
    when .vdir?
      case succ.key
      when "起"  then succ.val = "lên"
      when "进"  then succ.val = "vào"
      when "来"  then succ.val = "tới"
      when "过去" then succ.val = "qua"
      when "下去" then succ.val = "tiếp"
      when "下来" then succ.val = "lại"
      when "起来" then succ.val = "lên"
      end

      node = fold!(node, succ, dic: 3)
    else
      node = fold!(node, succ, dic: 3)
    end
  end

  def fold_left_verb!(node : MtNode, prev = node.prev?)
    return node unless prev

    case prev.key
    when "最", "那么", "这么", "非常"
      head, tail = swap!(prev, node)
      fold!(head, tail, node.tag, dic: 9)
    when "不太"
      prev.fold!(node, "không #{node.val} lắm")
    else
      fold!(prev, node, node.tag, dic: 9)
    end
  end

  def fold_verb_uzhe!(prev : MtNode, node : MtNode, succ = node.succ?) : MtNode
    node.val = ""

    if succ && succ.verbs?
      # succ = fold_verbs!(succ)
      fold!(prev, succ, PosTag::Verb, dic: 3)
    else
      fold!(prev, node, PosTag::Verb, dic: 5)
    end
  end
end
