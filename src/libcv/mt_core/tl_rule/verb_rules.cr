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
      when .adjts?, .verbs?, .preposes?, .unique?
        break unless fold = fold_verb_compl!(verb, succ)
        verb = fold
      when .adv_bu?
        break unless succ_2 = succ.succ?

        if succ_2.key == verb.key
          verb = fold_verb_bu_verb!(verb, succ, succ_2)
        elsif succ_2.vdir?
          verb = fold_verb_vdirs!(verb, succ_2)
        else
          break
        end
      when .numeric?
        if succ.key == "一" && (succ_2 = succ.succ?) && succ_2.key == verb.key
          verb = fold!(verb, succ_2.set!("phát"), verb.tag, dic: 6)
          break # TODO: still keep folding?
        end

        if val = PRE_NUM_APPROS[verb.key]?
          succ = fold_numbers!(succ) if succ.numbers?
          verb = fold_left_verb!(verb.set!(val), prev)
          return verb unless succ.nquants?
          return fold!(verb, succ, succ.tag, dic: 8)
        end

        verb = fold_left_verb!(verb, prev)
        return fold_verb_nquant!(verb, succ, prev)
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

  def fold_verb_bu_verb!(verb : MtNode, succ : MtNode, succ_2 : MtNode)
    succ.val = "hay"
    succ_2.val = "không"

    if (succ_3 = succ_2.succ?) && (succ_3.noun? || succ_3.pro_per?)
      succ_2.fix_succ!(succ_3.succ?)
      succ_3.fix_succ!(succ)
      succ_3.fix_prev!(verb)
      tag = PosTag::Vintr
    else
      tag = PosTag::Verb
    end

    fold!(verb, succ_2, tag: tag, dic: 5)
  end

  def fold_verb_auxils!(verb : MtNode, auxil : MtNode) : MtNode
    case auxil.tag
    when .ule?
      verb = fold_verb_ule!(verb, auxil)
      return verb unless (succ = verb.succ?) && succ.numeric?

      if is_pre_appro_num?(verb)
        succ = fold_numbers!(succ) if succ.numbers?
        return fold!(verb, succ, succ.tag, dic: 4)
      end

      return fold_verb_nquant!(verb, succ, has_ule: true)
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
    "向" => "hướng",
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
    # "对"  => "đúng",
    "成" => "thành",
    "懂" => "hiểu",
    "掉" => "mất",
    "走" => "đi",
    "够" => "đủ",
    "满" => "đầy",
    "倒" => "đổ",
    "下" => "xuống",
    "起" => "lên",
    "给" => "cho",
  }

  def fold_verb_compl!(verb : MtNode, compl : MtNode) : MtNode?
    unless val = VERB_COMPLS[compl.key]?
      return unless compl.pre_dui?

      if succ = compl.succ?
        return if succ.nouns? || succ.pro_per?
      end

      val = "đúng"
    end

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
