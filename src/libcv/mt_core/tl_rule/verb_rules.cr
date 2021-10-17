module CV::TlRule
  def fold_verbs!(node : MtNode, prev : MtNode? = nil) : MtNode
    if node.vpro?
      return node unless (succ = node.succ?) && succ.verbs?
      node = fold!(node, succ, succ.tag, dic: 5)
    end

    while succ = node.succ?
      case succ
      when .uzhi?
        fold_left_verb!(node, prev)
        return fold_uzhi!(succ, node)
      when .auxils?
        node = fold_verb_auxils!(node, succ)
        break if node.succ? == succ
      when .vdirs?
        node = fold_verb_vdirs!(node, succ)
      when .adjts?, .verbs?, .preposes?
        break unless fold = fold_verb_compl!(node, succ)
        node = fold
      when .adv_bu?
        break unless (succ_2 = succ.succ?) && succ_2.key == node.key
        succ.val = "hay"
        succ_2.val = "không"
        node = fold!(node, succ_2, PosTag::Verb, dic: 5)
      when .nquants?
        break if node.key == "小于"

        succ = fold_number!(succ) if succ.numbers?
        break unless succ.nquant? && !succ.succ?(&.nouns?)
        succ.val.sub("bả", "phát") if succ.key.ends_with?("把")

        node = fold_left_verb!(node, prev)
        return fold!(node, succ, PosTag::Vphrase, 6)
      when .suf_nouns?
        # node = fold_left_verb!(node, prev) if prev
        return fold_suf_noun!(node, succ)
      else
        break
      end

      break if node.succ? == succ
    end

    fold_left_verb!(node, prev)
  end

  def fold_verb_auxils!(node : MtNode, succ : MtNode) : MtNode
    case succ.tag
    when .ule?
      succ.val = "" unless keep_ule?(node, succ)
      node = fold!(node, succ, PosTag::Verb, dic: 5)

      return node unless (succ = node.succ?) && succ.nquants?
      succ = fold_number!(succ) if succ.numbers?
      return node unless succ.nquant?

      succ.val.sub("bả", "phát") if succ.key.ends_with?("把")
      fold!(node, succ, PosTag::Vphrase, dic: 6)
    when .ude2?
      return node unless (succ_2 = succ.succ?) && (succ_2.verb? || succ_2.veno?)
      succ_2 = fold_verbs!(succ_2)
      fold!(succ.heal!("mà"), succ_2, PosTag::Verb, dic: 5)
    when .ude3?
      fold_verb_ude3!(node, succ)
    when .uzhe?
      fold_verb_uzhe!(node, succ)
    when .uguo?
      fold!(node, succ, PosTag::Verb, dic: 6)
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

    fold!(verb, vdir, PosTag::Verb, dic: 5)
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
    fold!(node, succ, PosTag::Vphrase, dic: 6)
  end

  def fold_left_verb!(node : MtNode, prev : Nil)
    node
  end

  def fold_left_verb!(node : MtNode, prev = node.prev)
    case prev.key
    when "最", "那么", "这么", "非常"
      fold_swap!(prev, node, node.tag, dic: 5)
    when "不太"
      prev.val = "không quá"
      fold!(prev, node, node.tag, dic: 5)
    else
      fold!(prev, node, node.tag, dic: 5)
    end
  end

  def fold_verb_uzhe!(prev : MtNode, uzhe : MtNode, succ = uzhe.succ?) : MtNode
    uzhe.val = ""

    if succ && succ.verbs?
      # succ = fold_verbs!(succ)
      fold!(prev, succ, PosTag::Verb, dic: 5)
    else
      fold!(prev, uzhe, PosTag::Verb, dic: 6)
    end
  end
end
