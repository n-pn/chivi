module M1::TlRule
  SUFFIXES = {
    "的日子" => {"thời gian", PosTag::Ntime, true},
    "的时候" => {"lúc", PosTag::Postpos, true},
    "时"   => {"khi", PosTag::Postpos, true},
    "们"   => {"các", PosTag::Noun, true},
    "语"   => {"tiếng", PosTag::Nother, true},
    "性"   => {"tính", PosTag::Ajno, true},
    "所"   => {"nơi", PosTag::Posit, true},
    "界"   => {"giới", PosTag::Posit, false},
    "化"   => {"hoá", PosTag::Verb, false},
    "级"   => {"cấp", PosTag::Nattr, true},
    "型"   => {"hình", PosTag::Nattr, true},
    "状"   => {"dạng", PosTag::Nattr, true},
    "色"   => {"màu", PosTag::Nattr, true},
  }

  def fold_suffix!(suff : MtDefn, left : MtNode) : MtList?
    return unless left.nominal? || left.adjective? || left.verbal?
    return if left.v_shi? || left.v_you?

    postpos = false

    case suff.key
    when "时", "的时候", "的日子"
      return if left.adjective?
      postpos = true
      # when "们", "所", "级", "型", "状", "色", "性"
      #   # do nothing
      # else
      #   return if left.adjective?
    end

    if tuple = SUFFIXES[suff.key]?
      suff.val, ptag, flip = tuple
    else
      ptag, flip = PosTag::Noun, true
    end

    if postpos
      suff.set!(ptag)
      MtList.new(left, suff, tag: PosTag::Postpos, dic: 3, flip: true)
    else
      MtList.new(left, suff, tag: ptag, dic: 3, flip: flip)
    end
  end

  def fold_postpos!(postpos : MtList, left : MtNode) : MtList?
    return if left.adjective? || left.v_shi? || left.v_you?

    case postpos.list[1]
    when .nominal?
      return unless left.verbal? || left.preposes? || left.modifier?
    when .verbal?, .preposes?
      return unless left.subject? || left.adverbial?
    when .subject?
      return unless left.nominal?
    end

    left.fix_prev!(postpos.list[0])
    left.fix_succ!(postpos.list[1])
    postpos.list.insert(1, left)

    postpos
  end
end
