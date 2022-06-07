module CV::MtlV2::TlRule
  # ameba:disable Metrics/CyclomaticComplexity
  def fold_v_you!(vyou : MtNode, succ = vyou.succ?)
    return vyou unless noun = scan_noun!(succ)
    return fold_verb_other!(vyou) if vyou.prev?(&.verb?)

    case succ = noun.succ?
    when .nil?     then return vyou
    when .adv_bu4? then return vyou
    when .ude1?
      return fold_vyou_ude1(vyou, succ, noun)
    when .adverb?
      if succ.key == "这么" || succ.key == "那么"
        adverb, succ = succ, succ.succ?
        return vyou if succ.try(&.nominal?)
      end
    else
      if vyou.key == "有"
        if noun.key == "些" || noun.key == "点"
          node = fold!(vyou, noun, PosTag::Adverb, dic: 4)
          return fold_adverbs!(node)
        end

        return fold!(vyou, noun, PosTag::VerbObject, dic: 6)
      end
    end

    unless (tail = scan_adjt!(succ)) && (tail.adjective? || adverb && tail.verb_object?)
      return fold!(vyou, noun, PosTag::VerbObject, dic: 7)
    end

    if tail.starts_with?('不')
      return fold!(vyou, tail, PosTag::Unkn, 1)
    end

    output = MtNode.new("", "", PosTag::Unkn, dic: 1, idx: vyou.idx)
    output.fix_prev!(vyou.prev?)
    output.fix_succ!(tail.succ?)

    noun.fix_succ!(nil)
    noun.set_succ!(adverb) if adverb

    case vyou.key
    when "有"
      output.set_body!(tail)
      tail.fix_succ!(vyou.set!("có"))
    when "没有"
      adv_bu = MtNode.new("没", "không", PosTag::AdvBu4, 1, vyou.idx)
      output.set_body!(adv_bu)
      adv_bu.fix_succ!(tail)

      vyou = MtNode.new("有", "bằng", PosTag::VYou, 1, vyou.idx + 1)
      tail.fix_succ!(vyou)
      vyou.fix_succ!(noun)
    else
      return vyou
    end

    return output unless (succ = output.succ?) && (succ.ude1? || succ.ude3?)
    return output unless (tail = succ.succ?) && tail.key == "多"

    noun.fix_succ!(succ.set!(""))
    output.fix_succ!(tail.succ?)
    tail.fix_succ!(nil)

    output
  end

  def fold_vyou_ude1(vyou : MtNode, ude1 : MtNode, noun : MtNode)
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
end
