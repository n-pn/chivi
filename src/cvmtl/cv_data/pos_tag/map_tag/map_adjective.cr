struct MT::PosTag
  ADJT_MAP = load_map("map_adjt", :can_be_pred)
  AABN_MAP = load_map("map_aabn", :can_be_pred)

  def self.map_adjt(tag : String, key : String = "", has_alt = false)
    case tag[1]?
    when 'l' then new(:amix, :can_be_pred)
    when 'z' then new(:ades, :can_be_pred)
    when '!' then map_aabn(key, has_alt)
    else          map_adjt(key, has_alt)
    end
  end

  def self.map_aabn(key : String, has_alt = false)
    AABN_MAP[key]? || new(:amod, :can_be_pred)
  end

  def self.map_adjt(key : String, has_alt = false)
    ADJT_MAP[key]? || new(:adjt, :can_be_pred)
  end
end
