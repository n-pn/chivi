module MT::PosTag
  CapHuman = make(:cap_human, MtlPos.flags(Object, Proper, People, Ktetic))
  CapPlace = make(:cap_place, MtlPos.flags(Object, Proper, Locale, Ktetic))
  CapInsti = make(:cap_insti, MtlPos.flags(Object, Proper, Locale, Ktetic))
  CapBrand = make(:cap_brand, MtlPos.flags(Object, Proper))
  CapTitle = make(:cap_title, MtlPos.flags(Object, Proper, Ktetic))
  CapOther = make(:cap_other, MtlPos.flags(Object, Proper, Ktetic))

  def self.map_name(tag : String, key = "")
    case tag[1]?
    when 'r' then CapHuman
    when 's' then CapPlace
    when 't' then CapInsti
    when 'b' then CapBrand
    when 'w' then CapTitle
    else          CapOther
    end
  end

  Nword = make(:nword, MtlPos.flags(Object, Ktetic))
  Nform = make(:nform, MtlPos.flags(Object, Ktetic))
  Nobjt = make(:nobjt, MtlPos.flags(Object, Ktetic))

  Place = make(:place, MtlPos.flags(Object, Ktetic, Locale))
  Posit = make(:posit, MtlPos.flags(Object, Locale))

  Nattr = make(:nattr, MtlPos.flags(Object))
  Tword = make(:tword, MtlPos.flags(Object))
  Texpr = make(:texpr, MtlPos.flags(Object))

  def self.map_noun(tag : String, key = "", alt : String? = nil)
    case tag[1]?
    when 'a' then make(:nattr, :object)
    when 'h' then map_honor(alt)
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
      pos |= MtlPos::NoSpaceR if val[1] != ' '
    when .ends_with?('?')
      pos |= MtlPos::AtTail
      pos |= MtlPos::NoSpaceL if val[-2] != ' '
    else
      pos |= MtlPos::AtTail
    end

    make(tag, pos)
  end

  PLACE_MAP = load_map("map_place", MtlPos.flags(Object, Locale))
  TWORD_MAP = load_map("map_tword", MtlPos.flags(Object))

  def self.map_place(key : String)
    PLACE_MAP[key] ||= begin
      if is_locat?(key[-1])
        make(:posit, MtlPos.flags(Object, Locale))
      else
        make(:place, MtlPos.flags(Object, Locale, Ktetic))
      end
    end
  end

  def self.map_tword(key : String)
    # TODO: map time by key
    TWORD_MAP[key]? || Tword
  end

  def self.is_locat?(char : Char)
    {'边', '面', '头',
     '上', '下', '前', '后', '左', '右',
     '东', '西', '南', '北',
     '里', '外', '中', '内', '旁',
    }.includes?(char)
  end

  OBJECT_MAP = load_map("map_nobjt", MtlPos.flags(Object, Ktetic))

  WEAPON_CHARS = {'剑', '刀', '枪'}

  def self.map_nobjt(key : String)
    OBJECT_MAP[key] ||= begin
      pos = MtlPos.flags(Object, Ktetic)

      # guess type of object by last character

      char = key[-1]
      # skipp common suffixes `子`, `儿`
      if key.size > 1 && (char == '子' || char == '儿')
        char = key[-2]
      end

      case char
      when '剑', '刀', '枪'
        make(:weapon_obj, pos)
      when '米', '花', '盐', '糖', '麦', '谷'
        make(:inhand_obj, pos)
      else
        make(:normal_obj, pos)
      end
    end
  end
end
