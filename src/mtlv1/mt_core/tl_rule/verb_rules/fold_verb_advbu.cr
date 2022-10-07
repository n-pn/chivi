module CV::TlRule
  def fold_verb_advbu!(verb : BaseNode, adv_bu : BaseNode, succ = adv_bu.succ?) : BaseNode
    return verb unless succ

    if succ.key == verb.key
      fold_verb_advbu_verb!(verb, adv_bu, succ)
    elsif succ.vdir?
      fold_verb_vdirs!(verb, succ)
    else
      fold_verb_compl!(verb, succ).try { |x| verb = x } || verb
    end
  end

  def fold_verb_advbu_verb!(verb : BaseNode, adv_bu : BaseNode, verb_2 : BaseNode)
    adv_bu.val = "hay"
    verb_2.val = "không"

    if (tail = verb_2.succ?) && (tail.nominal? || tail.pro_pers?)
      verb_2.fix_succ!(tail.succ?)
      tail.fix_succ!(adv_bu)
      tail.fix_prev!(verb)
      tag = PosTag::Vint
    else
      tag = PosTag::Verb
    end

    fold!(verb, verb_2, tag: tag, dic: 5)
  end
end
