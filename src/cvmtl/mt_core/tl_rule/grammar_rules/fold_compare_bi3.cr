module CV::TlRule
  def fold_compare_bi3!(prepos : MtNode, succ = prepos.succ?, mode = 0)
    return prepos unless noun = scan_noun!(succ, mode: mode)
    return prepos unless (succ = scan_adjt!(noun.succ?)) && (succ.adjts? || succ.verb_object?)

    output = MtNode.new("", "", PosTag::Unkn, dic: 1, idx: prepos.idx)
    output.fix_prev!(prepos.prev?)
    output.fix_succ!(succ.succ?)
    noun.fix_succ!(nil)

    case prepos.key
    when "比"
      output.set_body!(succ)
      succ.fix_succ!(prepos.set!("hơn"))
    when "不比"
      adv_bu = MtNode.new("不", "không", PosTag::AdvBu, 1, prepos.idx)
      output.set_body!(adv_bu)
      adv_bu.fix_succ!(succ)

      prepos = MtNode.new("比", "bằng", PosTag::PreBi3, 1, prepos.idx + 1)
      succ.fix_succ!(prepos)

      prepos.fix_succ!(noun)
    else
      return prepos
    end

    return output unless (succ = output.succ?) && (succ.ude1? || succ.ude3?)
    return output unless (tail = succ.succ?) && tail.key == "多"

    noun.fix_succ!(succ.set!(""))
    output.fix_succ!(tail.succ?)
    tail.fix_succ!(nil)

    output
  end
end
