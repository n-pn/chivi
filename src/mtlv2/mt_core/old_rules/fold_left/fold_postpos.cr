module MT::TlRule
  # SUFFIXES = {
  #   "的日子" => {"thời gian", MapTag.make(:suf_time), true},
  #   "的时候" => {"lúc", MapTag.make(:suf_time), true},
  #   "时"   => {"khi", MapTag.make(:suf_time), true},
  #   "们"   => {"các", MapTag::Nword, true},
  #   "语"   => {"tiếng", MapTag::Nword, true},
  #   "性"   => {"tính", MapTag.make(:pl_ajno, MtlPos.flags(Adjtish, Nounish)), true},
  #   "化"   => {"hoá", MapTag.make(:verb, :verbish), false},
  #   "所"   => {"nơi", MapTag::Posit, true},
  #   "界"   => {"giới", MapTag::Posit, false},
  #   "级"   => {"cấp", MapTag::Nattr, true},
  #   "型"   => {"hình", MapTag::Nattr, true},
  #   "状"   => {"dạng", MapTag::Nattr, true},
  #   "色"   => {"màu", MapTag::Nattr, true},
  # }

  def fold_suffix!(suff : BaseNode, left = suff.prev?) : BaseNode
    return suff unless suff.is_a?(BaseTerm) && left
    return suff unless left.tag.content?

    case suff
    when .suf_men5?
      suff.val = "các"
      ptag = MapTag.make(:nobjt, MtlPos.flags(Nounish, Ktetic, Plural))
      BasePair.new(left.not_nil!, suff, ptag, flip: true)
    when .suf_time?
      left = fold_left!(left)
      BasePair.new(left.not_nil!, suff, MapTag::Texpr, flip: true)
    when .suf_zhi?
      suff.alt.try { |x| suff.val = x }
      left = fold_left!(left).not_nil!
      BasePair.new(left.not_nil!, suff, MapTag::Nform, flip: true)
    when .suf_verb?
      ptag = PosTag.map_verbal(left.key)
      BasePair.new(left, suff, ptag, flip: false)
    when .suf_xing?
      BasePair.new(left, suff, MapTag::Nattr, flip: true)
    else
      BasePair.new(left, suff, MapTag::Nform, flip: !suff.tag.at_tail?)
    end
  end
end
