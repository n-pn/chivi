module CV::TlRule
  SUFFIXES = {
    "的日子" => {"thời gian", PosTag::Ntime, true},
    "的时候" => {"lúc", PosTag::Postpos, true},
    "时"   => {"khi", PosTag::Postpos, true},
    "们"   => {"các", PosTag::Noun, true},
    "语"   => {"tiếng", PosTag::Nother, true},
    "性"   => {"tính", PosTag::Ajno, true},
    "所"   => {"nơi", PosTag::Place, true},
    "界"   => {"giới", PosTag::Place, false},
    "化"   => {"giới", PosTag::Verb, false},
    "级"   => {"cấp", PosTag::Nattr, true},
    "型"   => {"hình", PosTag::Nattr, true},
    "状"   => {"dạng", PosTag::Nattr, true},
    "色"   => {"màu", PosTag::Nattr, true},
  }

  def fold_suffix!(head : MtTerm, suff : MtTerm) : MtList?
    return false unless head.contws?
    return false if head.v_shi? || head.v_you?

    case suff.key
    when "时", "的时候", "的日子"
      return false if head.adjective?
    when "们", "所", "级", "型", "状", "色", "性"
      # do nothing
    else
      return unless head.nominal?
    end

    if tuple = SUFFIXES[suff.key]?
      suff.val, ptag, flip = tuple
    else
      ptag, flip = PosTag::Noun, false
    end

    MtList.new(head, suff, tag: ptag, dic: 3, flip: flip)
  end

  def fold_postpos!(head : MtTerm, suff : MtList) : MtList?
    return if head.adjective? || head.v_shi? || head.v_you?

    case suff.list[0]
    when .nominal?            then return unless head.verbal? || head.preposes? || head.modifier?
    when .verbal?, .preposes? then return unless head.subject? || head.adverbial?
    when .subject?            then return unless head.nominal?
    end

    suff.tap(&.add_head!(head))
  end
end
