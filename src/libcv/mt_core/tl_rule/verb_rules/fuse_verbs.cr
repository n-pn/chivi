module CV::TlRule
  COMPL_TAILS = {'完', '到', '着', '上', '下', '起', '好'}

  def fuse_verb!(verb : MtNode, succ = verb.succ?)
    # puts [verb, succ]

    case verb.key[-1]?
    when '在'
      flag = MtFlag::Checked | MtFlag::HasPreZai
      verb.flag!(flag)
    when '着'
      flag = MtFlag::Checked | MtFlag::HasUzhe
      verb.flag!(flag)
    when '了'
      flag = MtFlag::HasUle
      verb.flag!(flag)
    when .in?(COMPL_TAILS)
      verb.flag!(:checked)
    else
      return verb.flag!(:resolved) unless succ
      verb = fuse_verb_compl!(verb, succ)
    end

    fuse_verb_compl_extra!(verb)
  end

  # ameba:disable Metrics/CyclomaticComplexity
  def fuse_verb_compl!(verb : MtNode, succ : MtNode) : MtNode
    flag = verb.flag | MtFlag::Checked

    if succ.key == verb.key
      verb = fold!(verb, succ, verb.tag, dic: verb.dic)
      return verb.flag!(:resolved) unless succ = verb.succ?
    end

    if succ.ule?
      verb = fuse_verb_ule!(verb, succ)
      ule = succ
      return verb if verb.flag.resolved? || !(succ = verb.succ?)
      ule.val = "" unless succ.ends?
    end

    # puts [verb, succ]

    case succ.tag
    when .pre_dui?
      succ.val = "đúng"
    when .pre_zai?
      flag |= MtFlag::HasPreZai
    when .uzhe?
      succ.val = ""
      flag |= MtFlag::HasUzhe
    when .adj_hao?
      # TODO: check pronouns and numerals?
      return verb.flag!(flag) if succ.succ?(&.nominal?)
      succ.val = succ.succ? { |x| x.ule? || x.ends? } ? "tốt" : "xong"
    when .locative?
      return fuse_verb_locality!(verb, succ, flag)
    when .v_dircomp?
      succ.val = MtDict.verb_dir.get_val(succ.key) || succ.val
      flag |= MtFlag::HasVdir
    else
      if val = MtDict.verb_com.get_val(succ.key)
        succ.val = val
      else
        return verb.flag!(:checked)
      end
    end

    verb = fold!(verb, succ, PosTag::VerbPhrase, dic: 6)

    verb.flag!(flag)
  end

  def fuse_verb_locality!(verb : MtNode, succ : MtNode, flag = verb.flag)
    return verb unless succ.key == "中"

    if (tail = succ.succ?) && tail.ule?
      succ.val = "trúng"
      flag |= MtFlag::HasUle
      verb = fold!(verb, tail, verb.tag, dic: 6)
    else
      succ.val = "đang"
      verb = fold!(verb, succ, PosTag::Vintr, dic: 5, flip: true)
    end

    verb.flag!(flag)
  end

  def fuse_verb_compl_extra!(verb : MtNode, succ = verb.succ?) : MtNode
    case succ
    when nil then verb.flag!(:resolved)
    when .auxils?
      fuse_verb_auxils!(verb, succ)
    when .verbal?
      # return verb unless is_linking_verb?(verb, succ.succ?)
      fuse_verb_verb!(verb, succ)
    when .adv_bu4?
      fold_verb_advbu!(verb, succ)
    when .numeral?
      fuse_verb_numeral!(verb, succ)
    else
      verb.flag!(:checked)
    end
  end

  def fuse_verb_verb!(verb_1 : MtNode, verb_2 : MtNode) : MtNode
    verb_2 = MtDict.fix_verb!(verb_2) if verb_2.mixed?
    fold!(verb_1, verb_2, verb_2.tag, dic: 5).flag!(:checked)
  end

  def fuse_verb_numeral!(verb : MtNode, succ : MtNode) : MtNode
    if succ.key == "一" && (succ_2 = succ.succ?) && succ_2.key == verb.key
      verb = fold!(verb, succ_2.set!("phát"), verb.tag, dic: 6)
    end

    if val = PRE_NUM_APPROS[verb.key]?
      verb.val = val
      succ = fold_number!(succ) if succ.numbers?
      return verb unless succ.nquants?
      return fold!(verb, succ, succ.tag, dic: 8)
    end

    fold_verb_nquant!(verb, succ)
  end
end
