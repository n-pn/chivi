struct CV::PosTag
  PRONOUN_MAP = load_map("pronouns")

  ProDem = new(:pro_dem, :nounish)
  ProInt = new(:pro_int, :nounish)

  def self.map_pronoun(key : String, tag : String = "")
    PRONOUN_MAP[key] ||= begin
      case key[0]
      when '这', '那', '每'
        new(:pro_dem, MtlPos.flags(Nounish, CanSplit))
      when '几', '哪'
        new(:pro_int, MtlPos.flags(Nounish, CanSplit))
      when '本', '令', '贵', '舍', '爱'
        new(:pro_per_x, :nounish)
      else
        new(:pro_unkn, :nounish)
      end
    end

    # case tag[1]?
    # when 'z' then new(:pro_dem)
    # when 'y' then new(:pro_int)
    # when 'r' then new(:pro_per_x)
    # else          new(:pro_unkn)
    # end
  end
end
