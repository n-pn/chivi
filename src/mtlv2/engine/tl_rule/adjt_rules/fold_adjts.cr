module MtlV2::TlRule
  def fold_adjts!(adjt : BaseNode, adverb : BaseNode? = nil) : BaseNode
    while (succ = adjt.succ?) && !succ.ends?
      case succ
      when .v_dircomp?
        return fold_verbs!(MtDict.fix_verb!(adjt), adverb: adverb)
      when .junction?
        fold_adjt_junction!(junc: succ, prev: adjt).try { |x| adjt = x } || return adjt
      else
        break if !(succ.adjective?) || succ.key == "多"
        # TODO: check edge cases, like ajno
        adjt = fold!(adjt, succ, PosTag::Adjt, dic: 4)
      end
    end

    adjt = fold_adverb_node!(adverb, adjt, PosTag::AdjtPhrase) if adverb
    fold_adjt_after!(adjt)
  end

  # ameba:disable Metrics/CyclomaticComplexity
  def fold_adjt_after!(adjt : BaseNode)
    case succ = adjt.succ?
    when .nil? then adjt
    when .veno?
      succ = MtDict.fix_noun!(succ)
      fold_nouns!(noun: succ, defn: adjt)
    when .nominal?
      fold_nouns!(noun: succ, defn: adjt)
    when .verbal?
      fold_adjt_verb!(adjt, succ)
    when .ude1?
      if prev = adjt.prev?
        return adjt if prev.nominal? || prev.junction? # ||  (prev.comma? && prev.prev?(&.adjective?))
      end

      fold_adjt_ude1!(adjt, succ)
    when .auxils?  then fold_adjt_auxil!(adjt, succ)
    when .adv_bu4? then fold_adjt_adv_bu!(adjt, succ)
    else
      adjt
    end
  end

  def fold_modifier!(modi : BaseNode, succ = modi.succ?, nega : BaseNode? = nil) : BaseNode
    # puts [modi, succ, nega].colorize.green
    modi.val = "tất cả" if modi.key == "所有"

    modi = fold!(nega, modi, modi.tag, dic: 4) if nega
    return modi unless succ = modi.succ?

    MtDict.fix_noun!(succ) if succ.veno? || succ.ajno? || succ.adv_noun?
    # puts [modi, succ]

    return fold_adjts!(modi) unless succ.nominal?
    fold_nouns!(succ, defn: modi)
  end

  def fold_adjt_verb!(adjt : BaseNode, verb : BaseNode) : BaseNode
    return adjt if verb.v_shi? || verb.v_you?

    if (verb.key == "到") && (tail = verb.succ?) && tail.adjective?
      return fold!(adjt, tail, PosTag::AdjtPhrase, dic: 7)
    end

    return adjt if adjt.body? || adjt.key.size > 1
    fold_verbs!(verb, adverb: adjt)
  end

  def fold_adjt_auxil!(adjt : BaseNode, auxil : BaseNode) : BaseNode
    return adjt unless tail = auxil.succ?

    case auxil
    when .ule?
      return adjt unless tail.key == "点"
      auxil.val = ""
      fold!(adjt, tail.set!("chút"), PosTag::AdjtPhrase, dic: 6)
    when .ude2?
      fold_adjt_ude2!(adjt, auxil)
    when .uzhe?
      verb = MtDict.fix_verb!(adjt)
      fold_verbs!(verb)
    when .uzhi?
      fold_uzhi!(auxil, adjt)
    when .suffixes?
      fold_suffix!(adjt, auxil)
    else
      adjt
    end
  end

  def fold_adjt_ude1!(adjt : BaseNode, ude1 : BaseNode) : BaseNode
    adjt = fold!(adjt, ude1.set!(""), PosTag::DefnPhrase, dic: 3)
    return adjt if !(tail = adjt.succ?) || tail.ends?

    tail = fold_once!(tail)
    flip = false
    ptag = tail.tag

    if tail.key == "很"
      tail.val = "cực kỳ"
      ptag = adjt.tag
    elsif tail.verbal?
      adjt.tag = PosTag::Adverb
    elsif tail.object?
      flip = true
    else
      return adjt
    end

    fold!(adjt, tail, tag: ptag, flip: flip)
  end

  def fold_adjt_ude2!(adjt : BaseNode, ude2 : BaseNode) : BaseNode
    return adjt if adjt.prev?(&.noun?)
    return adjt unless (succ = ude2.succ?) && succ.verbal?

    adjt = fold!(adjt, ude2.set!("mà"), PosTag::Adverb, dic: 3)
    fold!(adjt, fold_verbs!(succ), PosTag::VerbPhrase, dic: 5)
  end

  def fold_adjt_adv_bu!(adjt : BaseNode, adv_bu4 : BaseNode, prev : BaseNode? = nil) : BaseNode
    return adjt unless tail = adv_bu4.succ?

    if prev && prev.adv_bu4?
      tail = fold_adv_bu!(adv_bu4, succ: tail)
      return fold!(adjt, tail, tail.tag, dic: 4)
    end

    return adjt unless tail.key == adjt.key

    adv_bu4.val = "hay"
    fold!(adjt, tail.set!("không"), PosTag::AdjtPhrase, dic: 4)
  end
end
