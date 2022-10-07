struct CV::PosTag
  PRONOUN_MAP = load_map("pronouns")

  ProDem = new(:pro_dem, :object)
  ProInt = new(:pro_int, :object)

  def self.map_pronoun(key : String, tag : String = "")
    PRONOUN_MAP[key] ||= begin
      case key[0]
      when '这', '那', '每'
        new(:pro_dem, MtlPos.flags(Object, CanSplit))
      when '几', '哪'
        new(:pro_int, MtlPos.flags(Object, CanSplit))
      when '本', '令', '贵', '舍', '爱'
        new(:pro_per_x, :object)
      else
        new(:pro_unkn, :object)
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
