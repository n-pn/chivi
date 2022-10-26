struct MT::PosTag
  def self.map_name(tag : String, key = "")
    case tag[1]?
    when 'r' then new(:human_name)
    when 's' then new(:place_name)
    when 't' then new(:insti_name)
    when 'b' then new(:brand_name)
    when 'w' then new(:title_name)
    else          new(:other_name)
    end
  end

  def self.map_noun(tag : String, key = "", alt : String? = nil)
    case tag[1]?
    when 'a' then new(:nattr, :object)
    when 'h' then map_honor(alt)
    when 'o' then map_nobjt(key)
    when 'l' then Nform
    else          Nword
    end
  end

  def self.map_honor(val : String?)
    res = new(:honortitle)

    case val
    when .nil?
      res.pos |= MtlPos::AtTail
    when .starts_with?('?')
      res.pos |= MtlPos::AtHead
      res.pos |= MtlPos::NoSpaceR if val[1] != ' '
    when .ends_with?('?')
      res.pos |= MtlPos::AtTail
      res.pos |= MtlPos::NoSpaceL if val[-2] != ' '
    else
      res.pos |= MtlPos::AtTail
    end

    res
  end

  PLACE_MAP = load_map("map_place", MtlPos.flags(Object, Placeword))

  def self.map_place(key : String)
    PLACE_MAP[key] ||= begin
      is_locat?(key[-1]) ? new(:posit) : new(:place)
    end
  end

  def self.is_locat?(char : Char)
    {'边', '面', '头',
     '上', '下', '前', '后', '左', '右',
     '东', '西', '南', '北',
     '里', '外', '中', '内', '旁',
    }.includes?(char)
  end

  OBJECT_MAP = load_map("map_nobjt", MtlPos.flags(Object, Ktetic))

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
        new(:weapon_obj, pos)
      when '米', '花', '盐', '糖', '麦', '谷'
        new(:inhand_obj, pos)
      else
        new(:normal_obj, pos)
      end
    end
  end

  TWORD_MAP = load_map("map_tword", MtlPos.flags(Object, MaybeAdv))

  def self.map_tword(key : String)
    # TODO: map time by key
    TWORD_MAP[key]? || new(:timeword)
  end
end
