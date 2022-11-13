module MT::PosTag
  ADJT_MAP = load_map("map_adjt")
  AABN_MAP = load_map("map_aabn")

  def self.map_adjt(tag : String, key : String = "", has_alt = false) : MtlTag
    case tag[1]?
    when 'l' then MtlTag::Amix
    when 'z' then MtlTag::Ades
    when '!' then AABN_MAP[key]? || MtlTag::Amod
    else          ADJT_MAP[key]? || MtlTag::Adjt
    end
  end
end
