struct M1::PosTag
  PROPOS = Pos::Pronouns

  # 代词 - pronoun - đại từ chưa phân loại
  ProUkn = new(Tag::ProUkn, PROPOS | Pos::Nominal)

  # 人称代词 - personal pronoun - đại từ nhân xưng
  ProPer = new(Tag::ProPer, Pos::Human | PROPOS)

  # 指示代词 - demonstrative pronoun - đại từ chỉ thị
  DEMPOS = Pos::ProDems | Pos::Pronouns
  ProDem = new(Tag::ProDem, DEMPOS)
  ProZhe = new(Tag::ProZhe, DEMPOS)
  ProNa1 = new(Tag::ProNa1, DEMPOS)
  ProJi  = new(Tag::ProJi, DEMPOS)

  # 疑问代词 - interrogative pronoun - đại từ nghi vấn
  INTPOS = Pos::ProInts | Pos::Pronouns
  ProInt = new(Tag::ProInt, INTPOS)
  ProNa2 = new(Tag::ProNa2, INTPOS)

  def self.parse_pronoun(tag : String, key : String)
    case tag[1]?
    when 'z' then parse_prodem(key)
    when 'y' then parse_proint(key)
    when 'r' then ProPer
    else          ProUkn
    end
  end

  def self.parse_prodem(key : String)
    case key
    when "这" then ProZhe
    when "那" then ProNa1
    when "几" then ProJi
    else          ProDem
    end
  end

  def self.parse_proint(key : ::String)
    case key
    when "哪" then ProNa2
    else          ProInt
    end
  end
end
