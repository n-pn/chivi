module MT::TlRule
  # SUFFIXES = {
  #   "的日子" => {"thời gian", PosTag.make(:suf_time), true},
  #   "的时候" => {"lúc", PosTag.make(:suf_time), true},
  #   "时"   => {"khi", PosTag.make(:suf_time), true},
  #   "们"   => {"các", PosTag::Nword, true},
  #   "语"   => {"tiếng", PosTag::Nword, true},
  #   "性"   => {"tính", PosTag.make(:pl_ajno, MtlPos.flags(Adjtish, Nounish)), true},
  #   "化"   => {"hoá", PosTag.make(:verb, :verbish), false},
  #   "所"   => {"nơi", PosTag::Posit, true},
  #   "界"   => {"giới", PosTag::Posit, false},
  #   "级"   => {"cấp", PosTag::Nattr, true},
  #   "型"   => {"hình", PosTag::Nattr, true},
  #   "状"   => {"dạng", PosTag::Nattr, true},
  #   "色"   => {"màu", PosTag::Nattr, true},
  # }

  def fold_suffix!(suff : MtNode, left = suff.prev?) : MtNode
    return suff unless suff.is_a?(MonoNode) && left
    return suff unless left.tag.content?

    case suff
    when .suf_men5?
      suff.val = "các"
      ptag = PosTag.make(:nobjt, MtlPos.flags(Nounish, Ktetic, Plural))
      PairNode.new(left.not_nil!, suff, ptag, flip: true)
    when .suf_verb?
      ptag = PosTag.map_verbal(left.key)
      PairNode.new(left, suff, ptag, flip: false)
    when .suf_xing?
      PairNode.new(left, suff, PosTag::Nattr, flip: true)
    else
      PairNode.new(left, suff, PosTag::Nform, flip: !suff.tag.at_tail?)
    end
  end
end
