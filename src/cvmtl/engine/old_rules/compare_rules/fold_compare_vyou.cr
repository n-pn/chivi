module MT::TlRule
  def fold_vyou!(vyou : MtNode, succ : MtNode)
    not_meiyou = vyou.key != "没有"

    if not_meiyou && succ.key_in?("些", "点")
      node = fold!(vyou, succ, MapTag::Adverb)
      return fold_adverbs!(node)
    end

    return vyou unless (noun = scan_noun!(succ)) && (tail = noun.succ?)
    return fold_vyou_ude1!(vyou, ude1: tail, noun: noun) if tail.ptcl_dep?

    fold_compare_vyou!(vyou, noun, tail)
  end

  def fold_vyou_ude1!(vyou : MtNode, ude1 : MtNode, noun : MtNode)
    unless tail = scan_noun!(ude1.succ?)
      return fold!(vyou, noun, MapTag::Vobj)
    end

    if find_verb_after(tail)
      ude1.set!("")
      head = fold!(vyou, noun, MapTag::Vobj)
      fold!(head, tail, tail.tag, flip: true)
    else
      defn = fold!(noun, ude1.set!("của"), MapTag::DcPhrase, flip: true)
      noun = fold!(defn, tail, tail.tag, flip: true)
      fold!(vyou, noun, MapTag::Vobj)
    end
  end

  # ameba:disable Metrics/CyclomaticComplexity
  def fold_compare_vyou!(vyou : MtNode, noun : MtNode, tail : MtNode)
    not_meiyou = vyou.key != "没有"
    adverb = nil

    if not_meiyou
      return vyou unless tail.advb_words? && tail.key_in?("这么", "那么")
      adverb = tail
    end

    case tail
    when .advb_words?
      tail = fold_adverbs!(tail)
    when .adjt_words?
      tail = fold_adjts!(tail)
    when .verbal_words?
      tail = fold_verbs!(tail)
    end

    unless tail.adjt_words? || tail.vobj?
      return fold!(vyou, noun, MapTag::Vobj)
    end

    adverb.val = "" if adverb
    noun.fix_succ!(tail.succ?)

    if not_meiyou
      vyou.val = vyou.val.sub("có", "như")

      head = tail
      head.fix_prev!(vyou.prev?)
      head.fix_succ!(vyou)
    else
      head = MonoNode.new("没", "không", MapTag::AdvBu4, 1, vyou.idx)
      head.fix_prev!(vyou.prev?)
      head.fix_succ!(tail)

      temp = MonoNode.new("有", "như", MapTag::VYou, 1, vyou.idx + 1)
      temp.fix_prev!(tail)
      temp.fix_succ!(noun)
    end

    output = BaseList.new(head, noun, idx: head.idx)

    return output unless (succ = output.succ?) && (succ.ptcl_dep? || succ.ptcl_der?)
    return output unless (tail = succ.succ?) && tail.key == "多"

    noun.fix_succ!(succ.set!(""))
    output.fix_succ!(tail.succ?)
    tail.fix_succ!(nil)

    output
  end
end
