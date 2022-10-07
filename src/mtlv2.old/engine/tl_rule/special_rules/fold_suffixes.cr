module MtlV2::TlRule
  # ameba:disable Metrics/CyclomaticComplexity
  def fold_suffix!(base : BaseNode, suff : BaseNode) : BaseNode
    if suff.key == "化"
      verb = fold!(base, suff, tag: PosTag::Verb, dic: 3, flip: false)
      return fold_verbs!(verb)
    end

    flip = true
    ptag = PosTag::Noun

    case suff.key
    when "们", "們"
      suff.val = "các"
    when "时", "的时候", "的日子"
      # puts [base, suff]
      return base if do_not_fold_suffixes?(base)

      case suff.key
      when "时"   then suff.val = "khi"
      when "的时候" then suff.val = "lúc"
      end

      ptag = PosTag::Texpr
    when "性"
      if (tail = suff.succ?) && tail.pt_dev?
        adverb = fold!(base, suff, PosTag::Adverb, dic: 4, flip: true)
        return fold_adverb_base!(adverb, succ: tail)
      end
    when "级", "型", "状", "色"
      ptag = PosTag::Nattr
    when "所"
      suff.val = "nơi"
    when "语"
      return base unless base..noun_words?
      suff.val = "tiếng"
    when "界"
      return base unless base..noun_words?
      flip = false
    end

    head = fold!(base, suff, tag: ptag, dic: 3, flip: flip)
    # TODO: skip fold_noun_noun in fold_nouns!
    fold_nouns!(head)
  end

  def do_not_fold_suffixes?(base : BaseNode)
    return false if base.adjective?
    return base.prev?(&.subject?) if base.verbal?
    return true unless prev = base.prev?
    prev.verbal? || prev.pt_dep?
  end
end
