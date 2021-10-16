module CV::TlRule
  def fold_verbs!(node : MtNode, succ = node.succ?, prev : MtNode? = nil)
    while node.verbs?
      break unless succ = node.succ?

      case succ
      when .uzhi?
        node = fold_left_verb!(node, prev) if prev
        return fold_uzhi!(succ, node)
      when .auxils?
        node = fold_verb_auxils!(node, succ)
        break if node.vphrase? || succ == node.succ?
      when .vdirs?
        node = fold_verb_vdirs!(node, succ)
      when .adjts?, .verbs?, .preposes?
        break unless fold = fold_verb_compl!(node, succ)
        node = fold
      when .adv_bu?
        break unless (succ_2 = succ.succ?) && succ_2.key == node.key
        succ.val = "hay"
        succ_2.val = "không"
        node = fold!(node, succ_2, dic: 2)
      when .nquants?
        succ = fold_number!(succ) if succ.numbers?
        break unless succ.nquant? && !succ.succ?(&.nouns?)
        fold!(node, succ, PosTag::Vphrase, 4)
        break
      when .suf_nouns?
        node = fold_left_verb!(node, prev) if prev
        return fold_suf_noun!(node, succ)
      else
        break
      end

      break if succ == node.succ?
    end

    node = fold_left_verb!(node, prev) if prev
    node
  end

  def fold_verb_auxils!(node : MtNode, succ : MtNode) : MtNode
    case succ.tag
    when .ule?
      succ.val = "" unless keep_ule?(node, succ)
      node = fold!(node, succ, dic: 2)

      return node unless (succ = node.succ?) && succ.nquants?
      succ = fold_number!(succ) if succ.numbers?
      return node unless succ.nquant?
      fold!(node, succ, PosTag::Vphrase, 6)
    when .ude2?
      return node unless (succ_2 = succ.succ?) && (succ_2.verb? || succ_2.veno?)
      succ_2 = fold_verbs!(succ_2)
      succ.val = "mà"
      fold!(succ, succ_2, PosTag::Verb, 6)
    when .ude3?
      fold_verb_ude3!(node, succ)
    when .uzhe?
      fold_verb_uzhe!(node, succ)
    when .uguo?
      fold!(node, succ, dic: 2)
    else
      node
    end
  end

  def fold_verb_vdirs!(verb : MtNode, vdir : MtNode) : MtNode
    case vdir.key
    when "起"  then vdir.val = "lên"
    when "进"  then vdir.val = "vào"
    when "来"  then vdir.val = "tới"
    when "过去" then vdir.val = "qua"
    when "下去" then vdir.val = "xuống"
    when "下来" then vdir.val = "lại"
    when "起来" then vdir.val = "lên"
    end

    fold!(verb, vdir, dic: 3)
  end

  VERB_VALS = {
    "到" => "đến",
    # "在"  => "ở",
    "见"  => "thấy",
    "着"  => "được",
    "住"  => "lấy",
    "不住" => "không nổi",
    "上"  => "lên",
    "开"  => "ra",
    "完"  => "xong",
    "好"  => "xong",
    "错"  => "sai",
    "对"  => "đúng",
    "成"  => "thành",
    "懂"  => "hiểu",
    "掉"  => "mất",
    "走"  => "đi",
    "够"  => "đủ",
    "满"  => "đầy",
    "倒"  => "đổ",
    "下"  => "xuống",
    "起"  => "lên",
    "给"  => "cho",
  }

  def fold_verb_compl!(node : MtNode, succ : MtNode) : MtNode?
    return unless val = VERB_VALS[succ.key]?
    succ.val = val
    fold!(node, succ, PosTag::Vphrase, dic: 7)
  end

  def fold_left_verb!(node : MtNode, prev = node.prev?)
    return node unless prev

    case prev.key
    when "最", "那么", "这么", "非常"
      fold_swap!(prev, node, node.tag, dic: 9)
    when "不太"
      prev.val = "không quá"
      fold!(prev, node, node.tag, dic: 9)
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
