module CV::TlRule
  def fold_verbs!(verb : MtNode, prev : MtNode? = nil) : MtNode
    if verb.vpro?
      return verb unless (succ = verb.succ?) && succ.verbs?
      verb = fold!(verb, succ, succ.tag, dic: 5)
    end

    while succ = verb.succ?
      case succ
      when .uzhi?
        verb = fold_left_verb!(verb, prev)
        return fold_uzhi!(succ, verb)
      when .uzhe?
        verb = fold_verb_uzhe!(verb, uzhe: succ)
        break
      when .auxils?
        verb = fold_verb_auxils!(verb, succ)
        break if verb.succ? == succ
      when .vdirs?
        verb = fold_verb_vdirs!(verb, succ)
      when .adjts?, .verbs?, .preposes?
        break unless fold = fold_verb_compl!(verb, succ)
        verb = fold
      when .adv_bu?
        break unless (succ_2 = succ.succ?) && succ_2.key == verb.key
        succ.val = "hay"
        succ_2.val = "không"
        verb = fold!(verb, succ_2, PosTag::Verb, dic: 5)
      when .nquants?
        if succ.key == "一" && (succ_2 = succ.succ?) && succ_2.key == verb.key
          verb = fold!(verb, succ_2.set!("phát"), verb.tag, dic: 6)
          break # TODO: still keep folding?
        end

        break if verb.key == "小于"

        succ = fold_number!(succ) if succ.numbers?
        break unless succ.nquant? && !succ.succ?(&.nouns?)
        succ.val.sub("bả", "phát") if succ.key.ends_with?("把")

        verb = fold_left_verb!(verb, prev)
        return fold!(verb, succ, PosTag::Vphrase, dic: 6)
      when .suf_nouns?
        verb = fold_left_verb!(verb, prev)
        return fold_suf_noun!(verb, succ)
      else
        break
      end

      break if verb.succ? == succ
    end

    fold_left_verb!(verb, left: prev)
  end

  def fold_verb_auxils!(verb : MtNode, auxil : MtNode) : MtNode
    case auxil.tag
    when .ule?
      auxil.val = "" unless keep_ule?(verb, auxil)
      verb = fold!(verb, auxil, PosTag::Verb, dic: 5)

      return verb unless (succ = verb.succ?) && succ.nquants?
      succ = fold_number!(succ) if succ.numbers?
      return verb unless succ.nquant?

      succ.val.sub("bả", "phát") if succ.key.ends_with?("把")
      fold!(verb, succ, PosTag::Vphrase, dic: 6)
    when .ude2?
      return verb unless (succ_2 = auxil.succ?) && (succ_2.verb? || succ_2.veno?)
      succ_2 = fold_verbs!(succ_2)
      auxil.set!("mà")
      fold!(verb, succ_2, PosTag::Verb, dic: 5)
    when .ude3?
      fold_verb_ude3!(verb, auxil)
    when .uguo?
      fold!(verb, auxil, PosTag::Verb, dic: 6)
    else
      verb
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

  VERB_COMPLS = {
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

  def fold_verb_compl!(verb : MtNode, compl : MtNode) : MtNode?
    return unless val = VERB_COMPLS[compl.key]?
    fold!(verb, compl.set!(val), PosTag::Vphrase, dic: 6)
  end

  def fold_left_verb!(verb : MtNode, left : Nil)
    verb
  end

  def fold_left_verb!(node : MtNode, left = node.prev)
    case left.key
    when "最", "那么", "这么", "非常"
      fold_swap!(left, node, node.tag, dic: 5)
    when "不太"
      left.val = "không quá"
      fold!(left, node, node.tag, dic: 5)
    else
      fold!(left, node, node.tag, dic: 5)
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
