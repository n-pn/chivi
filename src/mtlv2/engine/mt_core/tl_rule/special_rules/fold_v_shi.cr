module CV::MtlV2::TlRule
  def fold_v_shi!(vshi : MtNode, succ = vshi.succ?)
    return vshi unless succ

    # puts [vshi, succ]
    if vshi.body? && succ.verbal?
      return fold_verbs!(succ, adverb: vshi)
    end

    return vshi unless (succ = scan_noun!(succ)) && (tail = succ.succ?)
    tail.verbal? ? fold_verbs!(tail, adverb: vshi) : tail
  end
end
