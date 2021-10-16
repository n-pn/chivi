struct CV::PosTag
  # 能愿动词 - modal verb - động từ năng nguyện

  VMODPOS = Pos::Vmodals | Pos::Contws
  Vmodal  = new(Tag::Vmodal, VMODPOS)
  VmHui   = new(Tag::VmHui, VMODPOS)
  VmNeng  = new(Tag::VmNeng, VMODPOS)
  VmXiang = new(Tag::VmXiang, VMODPOS)

  @[AlwaysInline]
  def vmodals?
    @pos.vmodals?
  end

  def self.map_vmodals(key : ::String)
    case key
    when "会" then VmHui   # động từ `hội`
    when "能" then VmNeng  # động từ `năng`
    when "想" then VmXiang # động từ `tưởng`
    else          Vmodal
    end
  end
end
