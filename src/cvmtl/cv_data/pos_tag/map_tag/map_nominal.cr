module MT::PosTag
  def self.map_name(tag : String, key = "")
    case tag[1]?
    when 'r' then MtlTag::HumanName
    when 's' then MtlTag::PlaceName
    when 't' then MtlTag::InstiName
    when 'h' then MtlTag::HraceName
    when 'w' then MtlTag::TitleName
    when 'b' then MtlTag::BrandName
    when 'k' then MtlTag::SkillName
    else          MtlTag::OtherName
    end
  end

  def self.map_noun(tag : String, key = "")
    case tag[1]?
    when 'r' then MtlTag::Human # todo: map human words
    when 'h' then MtlTag::Honor
    when 's' then map_space(key)
    when 'o' then map_nobjt(key)
    when 't' then map_tword(key)
    when 'a' then MtlTag::Nattr
    when 'b' then MtlTag::Nabst
    when 'l' then MtlTag::Nmix
    else          MtlTag::Noun
    end
  end

  SPACE_MAP = load_map("map_space")

  def self.map_space(key : String)
    SPACE_MAP[key] ||= begin
      is_locat?(key[-1]) ? MtlTag::Posit : MtlTag::Place
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
      # guess type of object by last character

      char = key[-1]
      # skipp common suffixes `子`, `儿`
      char = key[-2] if key.size > 1 && char.in?('子', '儿')

      case char
      when '剑', '刀', '枪'
        MtlTag::Weapon
      when '米', '花', '盐', '糖', '麦', '谷'
        MtlTag::Inhand
      else
        MtlTag::Nobjt
      end
    end
  end

  TWORD_MAP = load_map("map_tword")

  def self.map_tword(key : String)
    # TODO: map time by key
    TWORD_MAP[key]? || MtlTag::Timeword
  end
end
