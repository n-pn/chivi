struct CV::PosTag
  Special = new(Tag::Special, Pos::Specials | Pos::Contws)

  AdjHao = new(Tag::AdjHao, Pos::Adjts | Pos::Specials | Pos::Contws)
  VShang = new(Tag::VShang, Pos::Specials | Pos::Contws)
  VXia   = new(Tag::VXia, Pos::Specials | Pos::Contws)
  VShi   = new(Tag::VShi, Pos::Verbs | Pos::Specials | Pos::Contws)
  VYou   = new(Tag::VYou, Pos::Verbs | Pos::Specials | Pos::Contws)

  def self.parse_special(key : ::String)
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
end
