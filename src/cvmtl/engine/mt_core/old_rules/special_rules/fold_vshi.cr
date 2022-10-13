module MT::TlRule
  def fold_v_shi!(vshi : MtNode, succ = vshi.succ?)
    # puts [vshi, succ]
    return vshi unless (succ = scan_noun!(succ)) && (tail = succ.succ?)

    tail = fold_verbs!(tail) if tail.verb_words?
    if tail.verb_words? && tail.succ?(&.pt_dep?)
      tag = succ.vobj? ? tail.tag : PosTag::SubjVerb
      fold!(succ, tail, tag: tag)
    end

    vshi
  end
end
