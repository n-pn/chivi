module CV::TlRule
  def fold_compare_bi3!(prepos : MtNode, succ = prepos.succ?, mode = 0)
    return prepos unless (noun = scan_noun!(succ, mode: mode)) && noun.object?
    return prepos unless (tail = scan_adjt!(noun.succ?)) && (tail.adjts? || tail.verb_object?)

    output = MtNode.new("", "", PosTag::Unkn, dic: 1, idx: prepos.idx)
    output.fix_prev!(prepos.prev?)
    output.fix_succ!(tail.succ?)

    noun.fix_succ!(nil)

    if prepos.key == "不比"
      adv_bu = MtNode.new("不", "không", PosTag::AdvBu, 1, prepos.idx)
      output.set_body!(adv_bu)
      adv_bu.fix_succ!(succ)

      prepos = MtNode.new("比", "bằng", PosTag::PreBi3, 1, prepos.idx + 1)
      succ.fix_succ!(prepos)

      prepos.fix_succ!(noun)
    else
      output.set_body!(tail)
      tail.fix_prev!(nil)
      tail.fix_succ!(prepos.set!("hơn"))
    end

    return output unless (succ = output.succ?) && succ.auxils?

    case succ
    when .ule?
      return output unless (tail = succ.succ?) && tail.key == "点"
      succ.val = ""
      fold!(output, tail.set!("chút"), PosTag::Aform, dic: 6)
    when .ude1?, .ude3?
      return output unless (tail = succ.succ?) && tail.key == "多"

      noun.fix_succ!(succ.set!(""))
      output.fix_succ!(tail.succ?)
      tail.fix_succ!(nil)
      output
    else
      output
    end
  end
end
