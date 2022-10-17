module MT::TlRule
  def fold_compare_bi3!(prepos : MtNode, succ = prepos.succ?, mode = 0)
    return prepos unless (noun = scan_noun!(succ, mode: mode)) && noun.object?

    if (succ = noun.succ?) && succ.verb_no_obj?
      noun = fold!(noun, succ, PosTag::SubjVerb)
    end

    if (tail = noun.succ?) && tail.pt_dep? && tail.succ?(&.maybe_adjt?)
      if noun.vform?
        flip = false
        tail.set!("")
      else
        flip = true
        tail.set!("của")
      end

      noun = fold!(noun, tail, PosTag::DcPhrase, flip: flip)
    end

    return prepos unless tail = scan_adjt!(noun.succ?)
    return prepos unless tail.adjt_words? || tail.vobjs?

    output = MonoNode.new("", "", PosTag::LitBlank, idx: prepos.idx)
    output.fix_prev!(prepos.prev?)
    output.fix_succ!(tail.succ?)

    noun.fix_succ!(nil)

    if prepos.key == "不比"
      adv_bu = MonoNode.new("不", "không", PosTag::AdvBu4, 1, prepos.idx)

      adv_bu.fix_succ!(prepos.succ?)
      adv_bu.fix_prev!(prepos.prev?)

      prepos = MonoNode.new("比", "bằng", PosTag::PreBi3, 1, prepos.idx + 1)

      prepos.fix_succ!(tail.succ?)
      tail.fix_succ!(prepos)
      prepos = tail

      output = BaseList.new(adv_bu, prepos, idx: adv_bu.idx)
    else
      prepos.set!("hơn")
      output = BaseList.new(prepos, tail, idx: prepos.idx, flip: true)
    end

    fold_compare_bi3_after!(output, noun)
  end

  def fold_compare_bi3_after!(node : MtNode, last : MtNode)
    return node unless (succ = node.succ?) && succ.particles? && (tail = succ.succ?)

    case succ
    when .pt_le?
      return node unless tail.key == "点"
      last.fix_succ!(succ.set!(""))
      node.fix_succ!(tail.succ?)
      tail.fix_succ!(nil)
      node.set!(PosTag::Aform)
    when .pt_dep?, .pt_der?
      return node unless tail.key == "多"
      last.fix_succ!(succ.set!(""))
      node.fix_succ!(tail.succ?)
      tail.fix_succ!(nil)
      node
    else
      node
    end
  end
end