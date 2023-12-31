module M1::TlRule
  def fold_vyou!(vyou : MtNode, succ : MtNode)
    not_meiyou = vyou.key != "没有"

    if not_meiyou && succ.key_in?("些", "点")
      node = fold!(vyou, succ, PosTag::Adverb, dic: 4)
      return fold_adverbs!(node)
    end

    return vyou unless (noun = scan_noun!(succ)) && (tail = noun.succ?)
    return fold_vyou_ude1!(vyou, ude1: tail, noun: noun) if tail.ude1?

    fold_compare_vyou!(vyou, noun, tail)
  end

  def fold_vyou_ude1!(vyou : MtNode, ude1 : MtNode, noun : MtNode)
    unless tail = scan_noun!(ude1.succ?)
      return fold!(vyou, noun, PosTag::VerbObject, dic: 6)
    end

    if find_verb_after(tail)
      ude1.set!("")
      head = fold!(vyou, noun, PosTag::VerbObject, dic: 7)
      fold!(head, tail, tail.tag, dic: 8, flip: true)
    else
      defn = fold!(noun, ude1.set!("của"), PosTag::DefnPhrase, dic: 3, flip: true)
      noun = fold!(defn, tail, tail.tag, dic: 4, flip: true)
      fold!(vyou, noun, PosTag::VerbObject, dic: 6)
    end
  end

  # ameba:disable Metrics/CyclomaticComplexity
  def fold_compare_vyou!(vyou : MtNode, noun : MtNode, tail : MtNode)
    not_meiyou = vyou.key != "没有"
    adverb = nil

    if not_meiyou
      return vyou unless tail.adverbial? && tail.key_in?("这么", "那么")
      adverb = tail
    end

    case tail
    when .adverbial?
      tail = fold_adverbs!(tail)
    when .adjective?
      tail = fold_adjts!(tail)
    when .verbal?
      tail = fold_verbs!(tail)
    end

    unless tail.adjective? || tail.verb_object?
      return fold!(vyou, noun, PosTag::VerbObject, dic: 7)
    end

    adverb.val = "" if adverb
    noun.fix_succ!(tail.succ?)

    if not_meiyou
      vyou.val = vyou.val.sub("có", "như")

      head = tail
      head.fix_prev!(vyou.prev?)
      head.fix_succ!(vyou)
    else
      head = MtDefn.new("没", "không", PosTag::AdvBu4, 1, vyou.idx)
      head.fix_prev!(vyou.prev?)
      head.fix_succ!(tail)

      temp = MtDefn.new("有", "như", PosTag::VYou, 1, vyou.idx + 1)
      temp.fix_prev!(tail)
      temp.fix_succ!(noun)
    end

    output = MtList.new(head, noun, dic: 1, idx: head.idx)

    return output unless (succ = output.succ?) && (succ.ude1? || succ.ude3?)
    return output unless (tail = succ.succ?) && tail.key == "多"

    noun.fix_succ!(succ.set!(""))
    output.fix_succ!(tail.succ?)
    tail.fix_succ!(nil)

    output
  end
end
