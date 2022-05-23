module CV::TlRule
  COMPL_TAILS = {'完', '到', '着', '上', '下', '起', '好'}

  def fuse_verb!(verb : MtNode, succ = verb.succ?)
    return verb.tap(&.add_flag(:resolved)) unless succ

    case verb.key[-1]
    when '在'
      flag = MtFlag::Checked | MtFlag::HasPreZai
      verb.add_flag(flag)
    when '着'
      flag = MtFlag::Checked | MtFlag::HasUzhe
      verb.add_flag(flag)
    else
      if COMPL_TAILS.includes?(verb.key[-1]?)
        verb.add_flag(:checked)
      else
        verb = fuse_verb_compl!(verb, succ)
      end
    end

    case succ = verb.succ?
    when nil then verb.add_flag(:resolved)
    when .auxils?
      fuse_verb_auxils!(verb, succ)
    else
      verb.add_flag(:checked)
    end
  end

  # ameba:disable Metrics/CyclomaticComplexity
  def fuse_verb_compl!(verb : MtNode, succ : MtNode) : MtNode
    flag = verb.flag | MtFlag::Checked

    if succ.key == verb.key
      verb = fold!(verb, succ, verb.tag, dic: verb.dic)
      return verb.tab(&.add_flag(:resolved)) unless succ = verb.succ?
    end

    case succ.tag
    when .pre_dui?
      return fuse_verb_predui!(verb, succ, flag)
    when .pre_zai?
      compl.val = "ở"
      flag |= MtFlag::HasPreZai
    when .uzhe?
      succ.val = ""
      flag |= MtFlag::HasUzhe
    when .adj_hao?
      # TODO: check pronouns and numerals?
      return verb.tab(&.add_flag(flag)) if succ.succ?(&.nominal?)
      succ.val = succ.succ? { |x| x.ule? || x.ends? } ? "tốt" : "xong"
    when .locality?
      return fuse_verb_locality!(verb, succ, flag)
    else
      if val = MtDict.get_val(:verb_dir, succ.key)
        succ.val = val
        flag |= MtFlag::HasVdir
      elsif val = MtDict.get_val(:verb_com, succ.key)
        succ.val = val
      end
    end

    verb = fold!(verb, succ, PosTag::VerbPhrase, dic: 6)
    verb.tap(&.add_flag(flag))
  end

  def fuse_verb_predui!(verb : MtNode, predui : MtNode, flag = verb.flag) : MtNode
    if (succ = predui.succ?) && (succ.verbal? || succ.puncts? || !succ.contw?)
      verb = fold!(verb, predui.set!("đúng"), verb.tag, dic: 6)
    end

    verb.tab(&.add_flag(flag))
  end

  def fuse_verb_locality!(verb : MtNode, succ : MtNode, flag = verb.flag)
    return verb unless succ.key == "中"

    if (tail = succ.succ?) && tail.ule?
      succ.val = "trúng"
      flag |= Flag::HasUle
      verb = fold!(verb, tail, verb.tag, dic: 6)
    else
      succ.val = "đang"
      verb = fold!(verb, succ, PosTag::Vintr, dic: 5, flip: true)
    end

    verb.tab(&.add_flag(flag))
  end

  def test(verb : MtNode)
    case succ = verb.succ?
    when .nil? then verb.tap(&.add_flag(:resolved))
    when .verbal?
      verb = fold_verb_verb!(verb, succ)
    when .adv_bu4?
      verb = fold_verb_advbu!(verb, succ)
    when .numeral?
      fold_verb_compare(verb).try { |x| return x }

      if succ.key == "一" && (succ_2 = succ.succ?) && succ_2.key == verb.key
        verb = fold!(verb, succ_2.set!("phát"), verb.tag, dic: 6)
        break # TODO: still keep folding?
      end

      if val = PRE_NUM_APPROS[verb.key]?
        succ = fold_number!(succ) if succ.numbers?

        verb = fold_left_verb!(verb.set!(val), prev)
        return verb unless succ.nquants?
        return fold!(verb, succ, succ.tag, dic: 8)
      end

      fold_verb_nquant!(verb, succ)
    end
  end
end
