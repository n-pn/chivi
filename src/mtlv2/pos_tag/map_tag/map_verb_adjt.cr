module MT::MapTag
  Aform = make(:aform, :none)
  Adesc = make(:adesc, :none)

  Adjt = make(:adjt, :none)
  Amod = make(:amod, :none)

  ADJTMOD_MAP = load_map("adjtmods", :none)
  ADJTVAL_MAP = load_map("adjtvals", :none)

  def self.map_adjt(tag : String, key : String = "", has_alt = false)
    case tag[1]?
    when 'l' then Aform
    when '!' then map_adjtmod(key)
    else          map_adjtval(key)
    end
  end

  def self.map_adjtmod(key : String)
    ADJTMOD_MAP[key] ||= Amod
  end

  def self.map_adjtval(key : String)
    ADJTVAL_MAP[key] ||= Adjt
  end

  VAUXIL_MAP = load_map("vauxils", :none)
  VOFORM_MAP = load_map("voforms", :none)
  VINTRA_MAP = load_map("vintras", :none)
  VERBAL_MAP = load_map("verbals", :none)

  Vmod = make(:vmod, :none)
  Verb = make(:verb, :none)
  Vint = make(:vint, :none)
  Vobj = make(:vobj, :none)

  Vform = make(:vform, :none)

  def self.map_verb(tag : String, key : String = "", has_alt = false) : self
    case tag[1]?
    when 'o' then map_voform(key)
    when '!' then map_vauxil(key)
    when 'i' then map_vintra(key, has_alt: has_alt)
    else          map_verbal(key, has_alt: has_alt)
    end
  end

  def self.map_voform(key : String)
    VOFORM_MAP[key] ||= begin
      # TODO: detect type by patterns
      Vobj
    end
  end

  def self.map_vauxil(key : String) : self
    VAUXIL_MAP[key] ||= begin
      case key[-1]
      when '是' then make(:v_shi, MtlPos.flags(None))
      when '有' then make(:v_you, MtlPos.flags(LinkVerb))
      else          make(:vpro, MtlPos.flags(Vauxil))
      end
    end
  end

  def self.map_vintra(key : String, has_alt = false)
    VINTRA_MAP[key]? || (has_alt ? make(:vinx, :none) : make(:vint, :none))
  end

  LINKVERB_CHARS = {'来', '去', '到', '出'}

  def self.map_verbal(key : String, has_alt = false) : self
    VERBAL_MAP[key] ||= begin
      tag = has_alt ? MtlTag::Vcmp : MtlTag::Verb
      pos = MtlPos::None

      last_char = key[-1]

      if key[0].in?(LINKVERB_CHARS) || last_char == '着'
        pos |= MtlPos::LinkVerb
      end

      case last_char
      when '着', '了', '过'
        pos |= MtlPos.flags(HasAsmCom)
      end

      make(tag, pos)
    end
  end
end
