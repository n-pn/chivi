module MT::PosTag
  PRONOUN_MAP = load_map("map_pronoun")

  def self.map_pronoun(key : String)
    PRONOUN_MAP[key] ||= begin
      case key[0]
      when '这', '那', '每'
        MtlTag::DemPron
      when '令', '贵', '舍', '爱', '本'
        MtlTag::PerPron
      when '几', '哪'
        MtlTag::IntPron
      else
        MtlTag::Pronoun
      end
    end
  end
end
