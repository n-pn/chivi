struct M1::PosTag
  Special = new(Tag::Special, Pos::Specials)

  AdjHao = new(Tag::AdjHao, Pos::Adjective | Pos::Specials)
  VShang = new(Tag::VShang, Pos::Specials)
  VXia   = new(Tag::VXia, Pos::Specials)
  VShi   = new(Tag::VShi, Pos::Verbal | Pos::Specials)
  VYou   = new(Tag::VYou, Pos::Verbal | Pos::Specials)

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
