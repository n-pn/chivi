module MT::PosTag
  def self.map_name(tag : String, key = "")
    case tag[1]?
    when 'r' then make(:human_name)
    when 's' then make(:place_name)
    when 't' then make(:insti_name)
    when 'h' then make(:hrace_name)
    when 'w' then make(:title_name)
    when 'b' then make(:brand_name)
    when 'k' then make(:skill_name)
    else          make(:other_name)
    end
  end

  def self.map_noun(tag : String, key = "")
    case tag[1]?
    when 'r' then make(:human) # todo: map human words
    when 'h' then make(:honor)
    when 's' then map_space(key)
    when 'o' then map_nobjt(key)
    when 't' then map_tword(key)
    when 'a' then make(:nattr)
    when 'b' then make(:nabst)
    when 'l' then make(:nmix)
    else          make(:noun)
    end
  end

  SPACE_MAP = load_map("map_place")

  def self.map_space(key : String)
    SPACE_MAP[key] ||= begin
      is_locat?(key[-1]) ? make(:posit) : make(:place)
    end
  end

  def self.is_locat?(char : Char)
    {'边', '面', '头',
     '上', '下', '前', '后', '左', '右',
     '东', '西', '南', '北',
     '里', '外', '中', '内', '旁',
    }.includes?(char)
  end

  OBJECT_MAP = load_map("map_nobjt")

  def self.map_nobjt(key : String)
    OBJECT_MAP[key] ||= begin
      pos = MtlPos.flags(Object, Ktetic)

      # guess type of object by last character

      char = key[-1]
      # skipp common suffixes `子`, `儿`
      char = key[-2] if key.size > 1 && char.in?('子', '儿')

      case char
      when '剑', '刀', '枪'
        make(:weapon, pos)
      when '米', '花', '盐', '糖', '麦', '谷'
        make(:inhand, pos)
      else
        make(:nsolid, pos)
      end
    end
  end

  TWORD_MAP = load_map("map_tword")

  def self.map_tword(key : String)
    # TODO: map time by key
    TWORD_MAP[key]? || make(:timeword)
  end
end
