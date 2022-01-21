module CV::TlRule
  def fold_compare_vyou!(vyou : MtNode, succ = vyou.succ?, mode = 0)
    return vyou unless noun = scan_noun!(succ, mode: mode)
    return vyou unless succ = noun.succ?

    if succ.key == "这么" || succ.key == "那么"
      proint, succ = succ, succ.succ?
    end

    unless (succ = scan_adjt!(succ)) && (succ.adjts? || succ.verb_object?)
      return fold!(vyou, noun, PosTag::Aform, dic: 7)
    end

    output = MtNode.new("", "", PosTag::Unkn, dic: 1, idx: vyou.idx)
    output.fix_prev!(vyou.prev?)
    output.fix_succ!(succ.succ?)

    noun.fix_succ!(nil)
    noun.set_succ!(proint) if proint

    case vyou.key
    when "有"
      output.set_body!(succ)
      succ.fix_succ!(vyou.set!("có"))
    when "没有"
      adv_bu = MtNode.new("没", "không", PosTag::AdvBu, 1, vyou.idx)
      output.set_body!(adv_bu)
      adv_bu.fix_succ!(succ)

      vyou = MtNode.new("有", "bằng", PosTag::VYou, 1, vyou.idx + 1)
      succ.fix_succ!(vyou)

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
