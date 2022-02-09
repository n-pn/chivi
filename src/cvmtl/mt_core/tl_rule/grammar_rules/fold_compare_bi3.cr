module CV::TlRule
  def fold_compare_bi3!(prepos : MtNode, succ = prepos.succ?, mode = 0)
    return prepos unless (noun = scan_noun!(succ, mode: mode)) && noun.object?

    if (tail = noun.succ?) && tail.ude1? && tail.succ?(&.maybe_adjt?)
      noun = fold!(noun, tail, PosTag::DefnPhrase, dic: 7, flip: true)
    end

    return prepos unless (tail = scan_adjt!(noun.succ?)) && (tail.adjts? || tail.verb_object?)

    output = MtNode.new("", "", PosTag::Unkn, dic: 1, idx: prepos.idx)
    output.fix_prev!(prepos.prev?)
    output.fix_succ!(tail.succ?)

    noun.fix_succ!(nil)

    if prepos.key == "不比"
      adv_bu = MtNode.new("不", "không", PosTag::AdvBu, 1, prepos.idx)
      output.set_body!(adv_bu)
      adv_bu.fix_succ!(tail)

      prepos = MtNode.new("比", "bằng", PosTag::PreBi3, 1, prepos.idx + 1)
      tail.fix_succ!(prepos)
      prepos.fix_succ!(noun)
    else
      output.set_body!(tail)
      tail.fix_prev!(nil)
      tail.fix_succ!(prepos.set!("hơn"))
    end

    fold_compare_bi3_after!(output)
  end

  def fold_compare_bi3_after!(node : MtNode)
    return node unless (succ = node.succ?) && succ.auxils? && (tail = succ.succ?)

    case succ
    when .ule?
      return node unless tail.key == "点"
      noun.fix_succ!(succ.set!(""))
      node.fix_succ!(tail.succ?)
      tail.fix_succ!(nil)
      node.set!(PosTag::Aform)
    when .ude1?, .ude3?
      return node unless tail.key == "多"
      noun.fix_succ!(succ.set!(""))
      node.fix_succ!(tail.succ?)
      tail.fix_succ!(nil)
      node
    else
      node
    end
  end
end
