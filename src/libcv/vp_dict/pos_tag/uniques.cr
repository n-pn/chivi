struct CV::PosTag
  Unique = new(Tag::Unique, Pos::Uniques | Pos::Contws)

  AdjHao = new(Tag::AdjHao, Pos::Adjts | Pos::Uniques | Pos::Contws)
  VShang = new(Tag::VShang, Pos::Verbs | Pos::Vdirs | Pos::Uniques | Pos::Contws)
  VXia   = new(Tag::VXia, Pos::Verbs | Pos::Vdirs | Pos::Uniques | Pos::Contws)
  VShi   = new(Tag::VShi, Pos::Verbs | Pos::Uniques | Pos::Contws)
  VYou   = new(Tag::VYou, Pos::Verbs | Pos::Uniques | Pos::Contws)

  @[AlwaysInline]
  def uniques?
    @pos.uniques?
  end

  def self.map_uniques(key : ::String)
    case key
    when "好" then AdjHao # "hảo"
    when "上" then VShang # "thượng"
    when "下" then VXia   # "hạ"
    when "是" then VShi   # "thị"
    when "有" then VYou   # "hữu"
    else          Unique
    end
  end
end
