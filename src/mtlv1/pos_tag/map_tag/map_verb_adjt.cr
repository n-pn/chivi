struct CV::PosTag
  Aform = new(:aform, :adjtish)
  Adesc = new(:adesc, :adjtish)

  Adjt = new(:adjt, :adjtish)
  Amod = new(:amod, :adjtish)

  ADJTMOD_MAP = load_map("adjtmods", :adjtish)
  ADJTVAL_MAP = load_map("adjtvals", :adjtish)

  def self.map_adjt(tag : String, key : String = "", vals = [] of String)
    case tag[1]?
    when 'f' then Aform
    when '!' then ADJTMOD_MAP[key] ||= Amod
    else          ADJTVAL_MAP[key] ||= Adjt
    end
  end

  VINTRA_MAP = load_map("vintras", :verbish)
  VAUXIL_MAP = load_map("vauxils", MtlPos.flags(Verbish, Vauxil))
  VERBAL_MAP = load_map("verbals", :verbish)

  Vmod = new(:vmod, :verbish)
  Verb = new(:verb, :verbish)

  Vform = new(:vform, :verbish)

  def self.map_verb(tag : String, key : String = "", vals = [] of String) : self
    case tag[1]?
    when '!' then map_vauxil(key)
    when 'i' then map_vintra(key, poly: vals.size > 1)
    else          map_verbal(key, poly: vals.size > 1)
    end
  end

  def self.map_vauxil(key : String) : self
    VAUXIL_MAP[key] ||= begin
      case key[-1]
      when '是' then new(:v_shi, MtlPos.flags(Verbish))
      when '有' then new(:v_you, MtlPos.flags(LinkVerb, Verbish))
      else          new(:vmod, MtlPos.flags(Verbish, Vauxil))
      end
    end
  end

  def self.map_vintra(key : String, poly = false)
    VINTRA_MAP[key]? || (poly ? new(:vinx, :verbish) : new(:vint, :verbish))
  end

  LINKVERB_CHARS = {'来', '去', '到', '出'}

  def self.map_verbal(key : String, poly = false) : self
    VERBAL_MAP[key] ||= begin
      tag = poly ? MtlTag::Vcmp : MtlTag::Verb
      pos = MtlPos::Verbish

      last_char = key[-1]

      if key[0].in?(LINKVERB_CHARS) || last_char == '着'
        pos |= MtlPos::LinkVerb
      end

      case last_char
      when '着', '了', '过'
        pos |= MtlPos.flags(HasAsmCom)
      end

      new(tag, pos)
    end
  end
end
