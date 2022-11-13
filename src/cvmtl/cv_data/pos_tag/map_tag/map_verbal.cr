module MT::PosTag
  VERB_MAP = load_map("map_verb")
  VINT_MAP = load_map("map_vint")
  VABN_MAP = load_map("map_vabn") # abn == abnormal

  def self.map_verb(tag : String, key : String = "")
    case tag[1]?
    when 'l' then MtlTag::Vmix
    when '!' then map_vauxil(key)
    when 'i' then map_vintra(key)
    else          map_verbal(key)
    end
  end

  def self.map_voform(key : String)
    VOBJ_MAP[key]? || begin
      # TODO: detect type by patterns
      MtlTag::Vobj
    end
  end

  def self.map_vauxil(key : String)
    VABN_MAP[key] ||= begin
      case key[-1]
      when '是' then MtlTag::VShi
      when '有' then MtlTag::VYou
      else          MtlTag::Vpro
      end
    end
  end

  def self.map_vintra(key : String)
    VINT_MAP[key]? || MtlTag::Vint
  end

  LINKVERB_CHARS = {'来', '去', '到', '出'}

  def self.map_verbal(key : String)
    VERB_MAP[key]? || begin
      fchar = key[0]
      lchar = key[-1]
      fchar.in?(LINKVERB_CHARS) || lchar == '着' ? MtlTag::Vlnk : MtlTag::Verb
    end
  end
end
