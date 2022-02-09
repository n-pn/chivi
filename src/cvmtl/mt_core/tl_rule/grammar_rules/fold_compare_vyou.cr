module CV::TlRule
  def fold_compare_vyou!(vyou : MtNode, succ = vyou.succ?, mode = 0)
    return vyou unless noun = scan_noun!(succ, mode: mode)

    case succ = noun.succ?
    when .nil? then return vyou
    when .adverb?
      if succ.key == "这么" || succ.key == "那么"
        adverb, succ = succ, succ.succ?
      end
    when .ude1?
      unless tail = scan_noun!(succ.succ?)
        return fold!(vyou, noun, PosTag::VerbObject, dic: 6)
      end

      if find_verb_after(tail)
        succ.set!("")
        head = fold!(vyou, noun, PosTag::VerbObject, dic: 7)
        return fold!(head, tail, tail.tag, dic: 8, flip: true)
      else
        defn = fold!(noun, succ.set!("của"), PosTag::DefnPhrase, dic: 3, flip: true)
        noun = fold!(defn, tail, tail.tag, dic: 4, flip: true)
        return fold!(vyou, noun, PosTag::VerbObject, dic: 6)
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

    unless (tail = scan_adjt!(tail)) && (tail.adjts? || adverb && tail.verb_object?)
      return fold!(vyou, noun, PosTag::VerbObject, dic: 7)
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
      adv_bu = MtNode.new("没", "không", PosTag::AdvBu, 1, vyou.idx)
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
end
