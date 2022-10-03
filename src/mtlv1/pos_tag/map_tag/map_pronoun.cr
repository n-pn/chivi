struct CV::PosTag
  PRONOUN_MAP = load_map("pronouns")

  def self.map_pronoun(key : String)
    PRONOUN_MAP[key] || begin
      case key[0]
      when '这', '那', '每'
        new(:pro_dem, :can_split)
      when '几', '哪'
        new(:pro_int, :can_split)
      when '本', '令', '贵'
        new(:pro_per_x)
      else
        new(:pro_unkn)
      end
    end

    case tag[1]?
    when 'z' then parse_prodem(key)
    when 'y' then parse_proint(key)
    when 'r' then key == "自己" ? ProZiji : ProPer
    else          ProUkn
    end
  end

  def self.parse_prodem(key : String)
    case key
    when "这" then ProZhe
    when "那" then ProNa1
    when "几" then ProJi
    else          ProDem
    end
  end

  def self.parse_proint(key : ::String)
    case key
    when "哪" then ProNa2
    else          ProInt
    end
  end
end
