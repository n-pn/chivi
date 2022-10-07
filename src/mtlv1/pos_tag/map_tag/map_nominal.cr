struct CV::PosTag
  CapHuman = new(:cap_human, MtlPos.flags(Object, Proper, People, Ktetic))
  CapPlace = new(:cap_place, MtlPos.flags(Object, Proper, Locale, Ktetic))
  CapInsti = new(:cap_insti, MtlPos.flags(Object, Proper, Locale, Ktetic))
  CapBrand = new(:cap_brand, MtlPos.flags(Object, Proper))
  CapTitle = new(:cap_title, MtlPos.flags(Object, Proper, Ktetic))
  CapOther = new(:cap_other, MtlPos.flags(Object, Proper, Ktetic))

  def self.map_name(tag : String, key = "")
    case tag[1]?
    when 'r' then CapHuman
    when 's' then CapPlace
    when 't' then CapInsti
    when 'l' then CapBrand
    when 'w' then CapTitle
    else          CapOther
    end
  end

  Nword = new(:nword, MtlPos.flags(Object, Ktetic))
  Nform = new(:nform, MtlPos.flags(Object, Ktetic))
  Nobjt = new(:nobjt, MtlPos.flags(Object, Ktetic))

  Place = new(:place, MtlPos.flags(Object, Ktetic, Locale))
  Posit = new(:posit, MtlPos.flags(Object, Locale))

  Nattr = new(:nattr, MtlPos.flags(Object))
  Tword = new(:tword, MtlPos.flags(Object))
  Texpr = new(:texpr, MtlPos.flags(Object))

  def self.map_noun(tag : String, key = "", vals = [] of String)
    case tag[1]?
    when 'a' then new(:nattr, :object)
    when 'h' then map_honor(vals[1]?)
    when 'o' then map_nobjt(key)
    when 'l' then Nform
    else          Nword
    end
  end

  def self.map_honor(val : String?)
    tag = MtlTag::Honor
    pos = MtlPos.flags(Object, People, Ktetic)

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

  PLACE_MAP = load_map("place_words", MtlPos.flags(Object, Locale))
  TWORD_MAP = load_map("time_words", MtlPos.flags(Object))

  def self.map_place(key : String)
    PLACE_MAP[key] ||= begin
      if is_locat?(key[-1])
        new(:posit, MtlPos.flags(Object, Locale))
      else
        new(:place, MtlPos.flags(Object, Locale, Ktetic))
      end
    end
  end

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

  OBJECT_MAP = load_map("objt_nouns", MtlPos.flags(Object, Ktetic))

  def self.map_nobjt(key : String)
    OBJECT_MAP[key] || begin
      # TODO: map objects by zh patterns
      new(:nobjt, MtlPos.flags(Object, Ktetic))
    end
  end
end
