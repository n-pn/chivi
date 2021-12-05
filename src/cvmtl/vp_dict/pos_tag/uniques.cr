struct CV::PosTag
  Unique = new(Tag::Unique, Pos::Uniques | Pos::Contws)

  AdjHao = new(Tag::AdjHao, Pos::Adjts | Pos::Uniques | Pos::Contws)
  VShang = new(Tag::VShang, Pos::Verbs | Pos::Vdirs | Pos::Uniques | Pos::Contws)
  VXia   = new(Tag::VXia, Pos::Verbs | Pos::Vdirs | Pos::Uniques | Pos::Contws)
  VShi   = new(Tag::VShi, Pos::Verbs | Pos::Uniques | Pos::Contws)
  VYou   = new(Tag::VYou, Pos::Verbs | Pos::Uniques | Pos::Contws)

  def self.map_uniques(key : ::String)
    case key
    when "好" then AdjHao # "hảo"
    when "上" then VShang # "thượng"
    when "下" then VXia   # "hạ"
    when .ends_with?("是")
      VShi # "thị"
    when .ends_with?("有")
      VYou # "hữu"
    else
      Unique
    end
  end
end
