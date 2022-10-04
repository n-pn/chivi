module MtlV2::TlRule
  def fold_adjt!(adjt : BaseNode, succ : Nil) : BaseNode
    adjt
  end

  def fold_adjt!(adjt : BaseNode, succ : Conjunct)
    return adjt unless succ.type.phrase? && (adjt_2 = cast_adjt(succ.succ?))
    adjt = AdjtTuple.new(adjt, succ, adjt_2, mark: 4)
    fold_adjt!(adjt, ajdt.succ?)
  end

  def fold_adjt!(adjt : BaseNode, succ : AdjtWord)
    adjt = AdjtTuple.new(adjt, succ, mark: 3)
    fold_adjt!(adjt)
  end

  def fold_adjt!(adjt : BaseNode, succ : VdirWord)
    verb = VerbPhrase.from_adjt(adjt, vdir: succ)
    fold_verb!(verb)
  end

  def fold_adjt!(adjt : BaseNode, succ : VerbNoun)
    node = succ.resolve!

    case node
    in VerbWord
      verb = VerbPhrase.new(node, adav: adjt)
      fold_verb!(verb, verb.succ?)
    in NounWord
      noun = NounPhrase.new(node, modi: adjt)
      fold_noun!(noun, noun.succ?)
    end
  end

  def fold_adjt!(adjt : BaseNode, succ : VerbWord)
    return fold_adjt_dao4!(adjt, succ) if succ.key == "到"
    return adjt unless adjt.flag.adverbial?

    verb = VerbPhrase.new(node, adav: adjt)
    fold_verb!(verb, verb.succ?)
  end

  def fold_adjt_dao4!(adjt : BaseNode, dao4 : VerbWord)
    return adjt unless (tail = dao4.succ?) && tail.ptag.adjective?
    adjt = AdjtTuple.new(adjt, dao4, succ)
    fold_adjt!(adjt, adjt.succ?)
  end

  def fold_adjt!(adjt : BaseNode, succ : NounWord | NounTuple | NounPhrase)
    return adjt unless adjt.modifier?
    noun = NounPhrase.new(node, modi: adjt)
    fold_noun!(noun, noun.succ?)
  end

  def fold_adjt!(adjt : BaseNode, succ : AuxilWord)
    case succ.kind
    when .ude1? then fold_adjt_ude1!(adjt, succ)
    when .ude2? then fold_adjt_ude2!(adjt, succ)
    else
      adjt
    end
  end

  # ameba:disable Metrics/CyclomaticComplexity
  def fold_adjt_after!(adjt : BaseNode)
    case succ = adjt.succ?
    when .nil? then adjt
    when .pl_veno?
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

    MtDict.fix_noun!(succ) if succ.pl_veno? || succ.pl_ajno? || succ.adv_noun?
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
