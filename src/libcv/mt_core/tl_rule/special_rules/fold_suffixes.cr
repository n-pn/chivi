module CV::TlRule
  # ameba:disable Metrics/CyclomaticComplexity
  def fold_suffix!(base : MtNode, suff : MtNode) : MtNode
    if suff.key == "化"
      verb = fold!(base, suff, tag: PosTag::Verb, dic: 3, flip: false)
      return fold_verbs!(verb)
    end

    flip = true
    ptag = PosTag::Noun

    case suff.key
    when "们", "們"
      suff.val = "các"
    when "时", "的时候"
      # puts [base, suff]
      if (base.nominal? && base.prev?(&.verb?)) || (base.verbal? && base.prev?(&.subject?))
        return base
      end

      suff.val = suff.key == "时" ? "khi" : "lúc"
      ptag = PosTag::Temporal
    when "性"
      if (tail = suff.succ?) && tail.ude2?
        adverb = fold!(base, suff, PosTag::Adverb, dic: 4, flip: true)
        return fold_adverb_base!(adverb, succ: tail)
      end
    when "级", "型", "状", "色"
      ptag = PosTag::Nattr
    when "所"
      suff.val = "nơi"
    when "语"
      return base unless base.nominal?
      suff.val = "tiếng"
    when "界"
      return base unless base.nominal?
      flip = false
    end

    head = fold!(base, suff, tag: ptag, dic: 3, flip: flip)
    # TODO: skip fold_noun_noun in fold_nouns!
    fold_nouns!(head)
  end
end