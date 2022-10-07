module CV::TlRule
  def fold_v_shi!(vshi : BaseNode, succ = vshi.succ?)
    # puts [vshi, succ]
    return vshi unless (succ = scan_noun!(succ)) && (tail = succ.succ?)

    tail = fold_verbs!(tail) if tail.verbal?
    if tail.verbal? && tail.succ?(&.pt_dep?)
      tag = succ.vobj? ? tail.tag : PosTag::SubjVerb
      fold!(succ, tail, tag: tag, dic: 8)
    end

    vshi
  end
end
