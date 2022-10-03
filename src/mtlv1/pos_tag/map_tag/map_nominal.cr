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

  Nform = new(:nform, :nounish)
  Nbase = new(:nbase, :nounish)
  Tword = new(:tword, :nounish)

  def self.map_noun(tag : String, key = "", vals = [] of String)
    case tag[1]?
    when 'a' then new(:nattr, :nounish)
    when 'h' then map_honor(vals[1]?)
    when 's' then map_place(key)
    when 'f' then map_place(key)
    when 'o' then map_nobjt(key)
    when 't' then Tword
    when 'l' then Nform
    else          Nbase
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

  PLACE_MAP = load_map("var/cvmtl/mapping/places.tsv", :locale)

  def self.map_place(key : String)
    PLACE_MAP[key] || begin
      is_locat?(key[-1]) ? new(:posit, :locale) : new(:place, MtlPos.flags(Locale, Ktetic))
    end
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
