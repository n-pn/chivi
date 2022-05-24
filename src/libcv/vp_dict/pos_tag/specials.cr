struct CV::PosTag
  Special = new(Tag::Special, Pos::Special | Pos::Contws)

  AdjHao = new(Tag::AdjHao, Pos.flags(Adjective, Special, Contws))

  VShang = new(Tag::VShang, Pos::Special | Pos::Contws)
  VXia   = new(Tag::VXia, Pos::Special | Pos::Contws)

  VShi = new(Tag::VShi, Pos.flags(Verbal, Special, Contws))
  VYou = new(Tag::VYou, Pos.flags(Verbal, Special, Contws))

  def self.parse_special(tag : String, key : String)
    case tag[1]?
    when 'v' then parse_verb_special(key)
    else          parse_unique_special(key)
    end
  end

  def self.parse_unique_special(key : String)
    case key
    when "好" then AdjHao # "hảo"
    when "上" then VShang # "thượng"
    when "下" then VXia   # "hạ"
    when .ends_with?('是')
      VShi # "thị"
    when .ends_with?('有')
      VYou # "hữu"
    else
      Special
    end
  end

  SVERB_POS = Pos.flags(Verbal, Special, Contws)

  V2Object = new(Tag::Verb, SVERB_POS, Sub::V2Object)
  VDircomp = new(Tag::Verb, SVERB_POS, Sub::VDircomp)
  VCombine = new(Tag::Verb, SVERB_POS, Sub::VCombine)
  VCompare = new(Tag::Verb, SVERB_POS, Sub::VCompare)

  def self.parse_verb_special(key : String)
    if key.ends_with?('是')
      return VShi # "thị"
    elsif key.ends_with?('有')
      return VYou # "hữu"
    end

    if MtDict.v2_objs.has_key?(key)
      V2Object
    elsif MtDict.verb_dir.has_key?(key)
      VDircomp
    elsif MtDict.v_combine.has_key?(key)
      VCombine
    elsif MtDict.v_compare.has_key?(key)
      VCompare
    else
      Verb
    end
  end
end
