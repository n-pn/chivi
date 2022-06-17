module MtlV2::TlRule
  def fuse_verb_auxils!(verb : BaseNode, auxil : BaseNode) : BaseNode
    case auxil.tag
    when .ule?
      fuse_verb_ule!(verb, auxil)
    when .ude2?
      fuse_verb_ude2!(verb, auxil)
    when .ude3?
      fuse_verb_ude3!(verb, auxil)
    when .uguo?
      fold!(verb, auxil, PosTag::Verb, dic: 6)
    when .usuo?
      fold!(verb, auxil.set!("nơi"), tag: PosTag::Noun, dic: 3, flip: true)
    when .uyy?
      adjt = fold!(verb, auxil.set!("như"), PosTag::Aform, dic: 7, flip: true)
      return adjt unless (succ = adjt.succ?) && succ.maybe_adjt?
      return adjt unless (succ = scan_adjt!(succ)) && succ.adjective?
      fold!(adjt, succ, PosTag::Aform, dic: 8)
    else
      verb
    end
  end

  def fuse_verb_ule!(verb : BaseNode, ule : BaseNode) : BaseNode
    return verb.flag!(:resolved) unless succ = ule.succ?

    tail = succ.key == verb.key ? succ : ule
    flag = verb.flag | MtFlag::HasUle | MtFlag::Checked

    verb = fold!(verb, tail, verb.tag, dic: 3)
    verb.flag!(flag)

    return verb.flag!(flag) unless (succ = verb.succ?) && succ.numeral?

    if is_pre_appro_num?(verb)
      succ = fold_number!(succ) if succ.numeral?
      return fold!(verb, succ, succ.tag, dic: 4)
    end

    fold_verb_nquant!(verb, succ, has_ule: true)
  end

  def fuse_verb_ude2!(verb : BaseNode, ude2 : BaseNode) : BaseNode
    succ = ude2.succ? { |x| fold_once!(x) }

    unless succ && (succ.verbal? || succ.preposes?)
      return verb.flag!(:resolved) if verb.v0_obj?

      ude2.val = "đất"
      verb = fold!(verb, ude2.set!("đất", PosTag::Noun), dic: 7)
      return verb.flag!(:resolved)
    end

    flag = succ.flag | MtFlag::Resolved
    ude2.val = ""

    verb = fold!(verb, succ, succ.tag, dic: 5, flip: true)
    verb.flag!(flag)
  end

  def fuse_verb_ude3!(verb : BaseNode, ude3 : BaseNode) : BaseNode
    return verb unless tail = ude3.succ?
    flag = verb.flag | MtFlag::HasUde3

    ude3.val = ""
    verb = fold!(verb, ude3, verb.tag, dic: 1)
    verb.flag = flag

    case tail
    when .pre_bi3?
      tail = fold_compare_bi3!(tail)
      fold!(verb, tail, PosTag::VerbObject, dic: 3)
    when .adverbial?
      tail = fold_adverbs!(tail)

      if tail.adjective?
        fold!(verb, tail, PosTag::AdjtPhrase, dic: 5)
      elsif tail.key == "很"
        tail.val = "cực kỳ"
        fold!(verb, tail, PosTag::AdjtPhrase, dic: 5)
      elsif tail.verbal?
        ude3.set!("đến")
        fold!(verb, tail, tail.tag, dic: 8)
      else
        verb
      end
    when .adjective?
      fold!(verb, tail, PosTag::AdjtPhrase, dic: 6)
    when .verbal?
      fuse_verb_compl!(verb, tail)
    else
      # TODO: handle verb form
      verb
    end
  end
end
