module CV::TlRule
  # -ameba:disable Metrics/CyclomaticComplexity
  def fold_suffixes!(base : MtNode, suff : MtNode) : MtNode
    flip = true
    ptag = PosTag::Noun

    case suff.key
    when "们"
      suff.val = "các"
      ptag = base.pro_per? ? base.tag : ptag
    when "时"
      suff.val = "khi"
      ptag = PosTag::Temporal
    when "所"
      suff.val = "nơi"
    when "语"
      return base unless base.nounish?
    when "界"
      return base unless base.nounish?
      flip = false
    when "性"
      ptag = suff.succ?(&.ude2?) ? PosTag::Adverb : PosTag::Noun
    when "级", "型", "状", "色"
      ptag = PosTag::Nattr
    end

    fold!(base, suff, tag: ptag, dic: 3, flip: flip)
  end
end
