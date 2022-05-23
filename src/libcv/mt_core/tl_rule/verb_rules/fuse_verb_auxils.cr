module CV::TlRule
  def fuse_verb_auxils!(verb : MtNode, auxil : MtNode) : MtNode
    case auxil.tag
    when .ule?
      fuse_verb_ule!(verb, auxil)
    when .ude2?
      fuse_verb_ude2!(verb, auxil)
    when .ude3?
      fuse_verb_ude3!(verb, auxil)
    when .uguo?
      fold!(verb, auxil, PosTag::Verb, dic: 6)
    when .uyy?
      adjt = fold!(verb, succ.set!("như"), PosTag::Aform, dic: 7, flip: true)
      adjt = fold_adverb_node!(prev, adjt) if prev

      return adjt unless (succ = adjt.succ?) && succ.maybe_adjt?
      return adjt unless (succ = scan_adjt!(succ)) && succ.adjective?
      fold!(adjt, succ, PosTag::Aform, dic: 8)
    else
      verb
    end
  end

  def fuse_verb_ule!(verb : MtNode, ule : MtNode)
    unless succ = ule.succ?
      return verb.tab(&.add_tag(:resolved))
    end

    tail = succ.key == verb.key ? succ : ule
    flag = verb.flag | MtFlag::HasUle

    verb = fold!(verb, tail, verb.tag, dic: 3)
    verb.add_flag(flag)

    return verb.add_tag(:resolved) unless succ = verb.succ?

    return verb unless succ.numeral?

    if is_pre_appro_num?(verb)
      succ = fuse_number!(succ) if succ.numeral?
      return fold!(verb, succ, succ.tag, dic: 4)
    end

    fold_verb_nquant!(verb, succ, has_ule: true)
  end

  def fuse_verb_ude2!(verb : MtNode, ude2 : MtNode) : MtNode
    succ = ude2.succ? { |x| fold_once!(x) }

    unless succ && (succ.verbal? || succ.preposes?)
      return verb.add_tag(:resolved) if verb.verb_no_obj?

      ude2.val = "đất"
      verb = fold!(verb, ude2.set!("đất", PosTag::Noun), dic: 7)
      return verb.tab(&.add_flag(:resolved))
    end

    flag = succ.flag | MtFlag::Resolved
    ude2.val = ""

    verb = fold!(verb, succ, succ.tag, dic: 5, flip: true)
    verb.tab(&.add_flag(flag))
  end

  def fuse_verb_ude3!(verb : MtNode, succ : MtNode) : MtNode
    return verb unless tail = succ.succ?
    succ.val = ""

    case tail
    when .pre_bi3?
      tail = fold_compare_bi3!(tail)
      fold!(verb, tail, PosTag::VerbObject, dic: 7)
    when .adverbial?
      tail = fold_adverbs!(tail)

      if tail.adjective?
        fold!(verb, tail, PosTag::Aform, dic: 5)
      elsif tail.key == "很"
        tail.val = "cực kỳ"
        fold!(verb, tail, PosTag::Aform, dic: 5)
      elsif tail.verbal?
        succ.set!("đến")
        fold!(verb, tail, tail.tag, dic: 8)
      else
        verb
      end
    when .adjective?
      fold!(verb, tail, PosTag::Aform, dic: 6)
    when .verbal?
      verb = fold!(verb, succ, PosTag::Verb, dic: 6)
      fuse_verb_compl!(verb, tail)
    else
      # TODO: handle verb form
      node
    end
  end
end
