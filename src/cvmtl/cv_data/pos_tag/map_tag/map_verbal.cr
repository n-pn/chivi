struct MT::PosTag
  VERB_MAP = load_map("map_verb", :can_be_pred)
  VINT_MAP = load_map("map_vint", :can_be_pred)
  VOBJ_MAP = load_map("map_vobj", :can_be_pred)
  VABN_MAP = load_map("map_vabn", :can_be_pred) # abn == abnormal

  def self.map_verb(tag : String, key : String = "", has_alt = false)
    case tag[1]?
    when 'l' then new(:vmix)
    when 'o' then map_voform(key)
    when '!' then map_vauxil(key)
    when 'i' then map_vintra(key, has_alt: has_alt)
    else          map_verbal(key, has_alt: has_alt)
    end
  end

  def self.map_voform(key : String)
    VOBJ_MAP[key]? || begin
      # TODO: detect type by patterns
      new(:vobj)
    end
  end

  def self.map_vauxil(key : String)
    VABN_MAP[key] ||= begin
      case key[-1]
      when '是' then new(:v_shi)
      when '有' then new(:v_you)
      else          new(:vpro)
      end
    end
  end

  def self.map_vintra(key : String, has_alt = false)
    VINT_MAP[key]? || (has_alt ? new(:vinx) : new(:vint))
  end

  LINKVERB_CHARS = {'来', '去', '到', '出'}

  def self.map_verbal(key : String, has_alt = false)
    VERB_MAP[key] ||= begin
      last_char = key[-1]

      tag = has_alt ? MtlTag::Vcmp : MtlTag::Verb
      pos = MtlPos::CanBePred

      pos |= MtlPos::Vlinking if key[0].in?(LINKVERB_CHARS) || last_char == '着'
      pos |= MtlPos.flags(HasAspect) if last_char.in?('着', '了', '过', '所')

      new(tag, pos)
    end
  end
end
