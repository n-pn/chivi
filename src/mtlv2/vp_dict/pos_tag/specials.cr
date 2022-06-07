struct CV::MtlV2::PosTag
  Special = new(Tag::Special, Pos::Special | Pos::Contws)

  AdjHao = new(Tag::AdjHao, Pos.flags(Adjective, Special, Contws))

  VShang = new(Tag::VShang, Pos::Special | Pos::Contws)
  VXia   = new(Tag::VXia, Pos::Special | Pos::Contws)

  def self.parse_special(tag : String, key : String)
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
