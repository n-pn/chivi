module MT::TlRule
  def fold_verb_advbu!(verb : MtNode, adv_bu : MtNode, succ = adv_bu.succ?) : MtNode
    return verb unless succ

    if succ.key == verb.key
      fold_verb_advbu_verb!(verb, adv_bu, succ)
    elsif succ.vdir?
      fold_verb_vdirs!(verb, succ)
    else
      fold_verb_compl!(verb, succ).try { |x| verb = x } || verb
    end
  end

  def fold_verb_advbu_verb!(verb : MtNode, adv_bu : MtNode, verb_2 : MtNode)
    adv_bu.val = "hay"
    verb_2.val = "không"

    if (tail = verb_2.succ?) && (tail.noun_words? || tail.pro_pers?)
      verb_2.fix_succ!(tail.succ?)
      tail.fix_succ!(adv_bu)
      tail.fix_prev!(verb)
      tag = PosTag::Vint
    else
      tag = PosTag::Verb
    end

    fold!(verb, verb_2, tag: tag)
  end
end
