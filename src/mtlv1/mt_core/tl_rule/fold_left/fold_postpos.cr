module CV::TlRule
  # SUFFIXES = {
  #   "的日子" => {"thời gian", PosTag.new(:suf_time), true},
  #   "的时候" => {"lúc", PosTag.new(:suf_time), true},
  #   "时"   => {"khi", PosTag.new(:suf_time), true},
  #   "们"   => {"các", PosTag::Nword, true},
  #   "语"   => {"tiếng", PosTag::Nword, true},
  #   "性"   => {"tính", PosTag.new(:pl_ajno, MtlPos.flags(Adjtish, Nounish)), true},
  #   "化"   => {"hoá", PosTag.new(:verb, :verbish), false},
  #   "所"   => {"nơi", PosTag::Posit, true},
  #   "界"   => {"giới", PosTag::Posit, false},
  #   "级"   => {"cấp", PosTag::Nattr, true},
  #   "型"   => {"hình", PosTag::Nattr, true},
  #   "状"   => {"dạng", PosTag::Nattr, true},
  #   "色"   => {"màu", PosTag::Nattr, true},
  # }

  def fold_suffix!(suff : BaseNode, left = suff.prev?) : BaseNode
    return suff unless suff.is_a?(MtTerm) && left
    return suff unless left.tag.content?

    case suff
    when .suf_men5?
      suff.val = "các"
      ptag = PosTag.new(:nobjt, MtlPos.flags(Nounish, Ktetic, Plural))
      BasePair.new(left.not_nil!, suff, ptag, dic: 1, flip: true)
    when .suf_time?
      left = fold_left!(left)
      BasePair.new(left.not_nil!, suff, PosTag::Texpr, dic: 1, flip: true)
    when .suf_zhi?
      suff.alt.try { |x| suff.val = x }
      left = fold_left!(left).not_nil!
      BasePair.new(left.not_nil!, suff, PosTag::Nform, dic: 2, flip: true)
    when .suf_verb?
      ptag = PosTag.map_verbal(left.key)
      BasePair.new(left, suff, ptag, dic: 1, flip: false)
    when .suf_xing?
      BasePair.new(left, suff, PosTag::Nattr, dic: 2, flip: true)
    else
      BasePair.new(left, suff, PosTag::Nform, dic: 2, flip: !suff.tag.at_tail?)
    end
  end
end
