module MT::MapTag
  PRONOUN_MAP = load_map("pronouns")

  ProDem = make(:pro_dem, :object)
  ProInt = make(:pro_int, :object)

  def self.map_pronoun(key : String, tag : String = "")
    PRONOUN_MAP[key] ||= begin
      case key[0]
      when '这', '那', '每'
        make(:pro_dem, MtlPos.flags(Object, CanSplit))
      when '几', '哪'
        make(:pro_int, MtlPos.flags(Object, CanSplit))
      when '本', '令', '贵', '舍', '爱'
        make(:pro_per_x, :object)
      else
        make(:pro_unkn, :object)
      end
    end

    # case tag[1]?
    # when 'z' then make(:pro_dem)
    # when 'y' then make(:pro_int)
    # when 'r' then make(:pro_per_x)
    # else          make(:pro_unkn)
    # end
  end
end
