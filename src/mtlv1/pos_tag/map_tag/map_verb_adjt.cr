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
    when 'z' then Adesc
    when 'b' then Amod
    when '!' then ADJTMOD_MAP[key] || Amod
    else          ADJTVAL_MAP[key] || Adjt
    end
  end

  VINTRA_MAP = load_map("vintras", :verbish)
  VAUXIL_MAP = load_map("vauxils", :verbish)
  VERBAL_MAP = load_map("verbals", :verbish)

  Vmod = new(:vmod, :verbish)
  Verb = new(:verb, :verbish)

  Vform = new(:vform, :verbish)

  def self.map_verb(tag : String, key : String = "", vals = [] of String)
    case tag[1]?
    when 'n' then new(:pl_veno, MtlPos.flags(Nounish, Verbish))
    when 'd' then new(:pl_vead, MtlPos.flags(Advbial, Verbish))
    when '!' then VAUXIL_MAP[key] || new(:vmod, :verbish)
    when 'i' then VINTRA_MAP[key] || (vals.size > 1 ? new(:vinx) : new(:vint))
    else          VERBAL_MAP[key] || (vals.size > 1 ? new(:verb) : new(:vcmp))
    end
  end
end
