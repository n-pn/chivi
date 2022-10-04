struct CV::PosTag
  CapHuman = new(:cap_human, MtlPos.flags(Nounish, Proper, People, Ktetic))
  CapAffil = new(:cap_affil, MtlPos.flags(Nounish, Proper, Locale, Ktetic))
  CapBrand = new(:cap_brand, MtlPos.flags(Nounish, Proper))
  CapTitle = new(:cap_title, MtlPos.flags(Nounish, Proper, Ktetic))
  CapOther = new(:cap_other, MtlPos.flags(Nounish, Proper, Ktetic))

  def self.map_name(tag : String, key = "")
    case tag[1]?
    when 'r' then CapHuman
    when 'a' then CapAffil
    when 'l' then CapBrand
    when 'w' then CapTitle
    else          CapOther
    end
  end

  Nform = new(:nform, MtlPos.flags(Nounish, Ktetic))
  Nword = new(:nword, MtlPos.flags(Nounish, Ktetic))

  def self.map_noun(tag : String, key = "", vals = [] of String)
    case tag[1]?
    when 'a' then new(:nattr, :nounish)
    when 'h' then map_honor(vals[1]?)
    when 'o' then map_nobjt(key)
    when 'l' then Nform
    else          Nword
    end
  end

  def self.map_honor(val : String?)
    tag = MtlTag::Honor
    pos = MtlPos.flags(Nounish, People, Ktetic)

    case val
    when .nil?
      pos |= MtlPos::AtTail
    when .starts_with?('?')
      pos |= MtlPos::AtHead
      pos |= MtlPos::NoWsAfter if val[1] != ' '
    when .ends_with?('?')
      pos |= MtlPos::AtTail
      pos |= MtlPos::NoWsBefore if val[-2] != ' '
    else
      pos |= MtlPos::AtTail
    end

    new(tag, pos)
  end

  PLACE_MAP = load_map("locations", MtlPos.flags(Nounish, Locale))

  def self.map_place(key : String)
    PLACE_MAP[key] ||= begin
      is_locat?(key[-1]) ? new(:posit, :locale) : new(:place, MtlPos.flags(Locale, Ktetic))
    end
  end

  TWORD_MAP = load_map("timewords", :nounish)

  Tword = new(:tword, :nounish)

  def self.map_tword(key : String)
    # TODO: map time by key
    TWORD_MAP[key] ||= Tword
  end

  def self.is_locat?(char : Char)
    {'边', '面', '头',
     '上', '下', '前', '后', '左', '右',
     '东', '西', '南', '北',
     '里', '外', '中', '内', '旁',
    }.includes?(char)
  end

  def self.map_nobjt(key : String)
    new(:nobjt, :nounish)
  end
end
