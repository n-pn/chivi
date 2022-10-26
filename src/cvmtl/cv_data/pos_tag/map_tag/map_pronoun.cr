module MT::PosTag
  PRONOUN_MAP = load_map("map_pronoun")

  def self.map_pronoun(key : String, tag : String = "")
    PRONOUN_MAP[key] ||= begin
      case key[0]
      when '这', '那', '每', '本'
        make(:dem_pron, MtlPos.flags(Object, CanSplit))
      when '令', '贵', '舍', '爱'
        make(:per_pron, MtlPos.flags(Object, Ktetic, Humankind))
      when '几', '哪'
        make(:int_pron, MtlPos.flags(Object, CanSplit))
      else
        make(:pronoun, MtlPos.flags(Object, Ktetic))
      end
    end
  end
end
