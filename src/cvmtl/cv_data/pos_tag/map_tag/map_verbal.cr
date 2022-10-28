module MT::PosTag
  VERB_MAP = load_map("map_verb")
  VINT_MAP = load_map("map_vint")
  VOBJ_MAP = load_map("map_vobj")
  VABN_MAP = load_map("map_vabn") # abn == abnormal

  def self.map_verb(tag : String, key : String = "", has_alt = false)
    case tag[1]?
    when 'l' then make(:vmix)
    when 'o' then map_voform(key)
    when '!' then map_vauxil(key)
    when 'i' then map_vintra(key, has_alt: has_alt)
    else          map_verbal(key, has_alt: has_alt)
    end
  end

  def self.map_voform(key : String)
    VOBJ_MAP[key]? || begin
      # TODO: detect type by patterns
      make(:vobj)
    end
  end

  def self.map_vauxil(key : String)
    VABN_MAP[key] ||= begin
      case key[-1]
      when '是' then make(:v_shi)
      when '有' then make(:v_you)
      else          make(:vpro)
      end
    end
  end

  def self.map_vintra(key : String, has_alt = false)
    VINT_MAP[key]? || (has_alt ? make(:vinx) : make(:vint))
  end

  LINKVERB_CHARS = {'来', '去', '到', '出'}

  def self.map_verbal(key : String, has_alt = false)
    VERB_MAP[key] ||= begin
      last_char = key[-1]

      tag = has_alt ? MtlTag::Vcmp : MtlTag::Verb
      pos = MtlPos::CanBePred

      pos |= MtlPos::Vlinking if key[0].in?(LINKVERB_CHARS) || last_char == '着'
      pos |= MtlPos.flags(HasAspcmpl) if last_char.in?('着', '了', '过', '所')

      make(tag, pos)
    end
  end
end
