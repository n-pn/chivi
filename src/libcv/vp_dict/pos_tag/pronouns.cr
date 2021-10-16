struct CV::PosTag
  PROPOS = Pos::Pronouns | Pos::Contws

  # 代词 - pronoun - đại từ chưa phân loại
  Pronoun = new(Tag::Pronoun, PROPOS)

  # 人称代词 - personal pronoun - đại từ nhân xưng
  ProPer = new(Tag::ProPer, PROPOS)

  # 指示代词 - demonstrative pronoun - đại từ chỉ thị
  DEMPOS = Pos::ProDems | Pos::Pronouns | Pos::Contws
  ProDem = new(Tag::ProDem, DEMPOS)
  ProZhe = new(Tag::ProDem, DEMPOS)
  ProNa1 = new(Tag::ProDem, DEMPOS)

  # 疑问代词 - interrogative pronoun - đại từ nghi vấn
  INTPOS = Pos::ProInts | Pos::Pronouns | Pos::Contws
  ProInt = new(Tag::ProInt, INTPOS)
  ProNa2 = new(Tag::ProInt, INTPOS)
  ProJi  = new(Tag::ProInt, INTPOS)

  @[AlwaysInline]
  def pronouns?
    @pos.pronouns?
  end

  @[AlwaysInline]
  def pro_dems?
    @pos.pro_dems?
  end

  @[AlwaysInline]
  def pro_ints?
    @pos.pro_ints?
  end

  def self.map_pro_dems(key : ::String)
    case key
    when "这" then ProZhe
    when "那" then ProNa1
    else          ProDem
    end
  end

  def self.map_pro_ints(key : ::String)
    case key
    when "哪" then ProNa2
    when "几" then ProJi
    else          ProInt
    end
  end
end
