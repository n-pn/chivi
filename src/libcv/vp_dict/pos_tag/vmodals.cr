struct CV::PosTag
  VMODALS = {
    # 能愿动词 - modal verb - động từ năng nguyện
    {"vm", "Vmodal", Pos::Vmodals | Pos::Contws},
    # 动词 “会” -
    {"vm_hui", "Vhui", Pos::Vmodals | Pos::Contws},
    # 动词 “能” -
    {"vm_neng", "Vneng", Pos::Vmodals | Pos::Contws},
    # 动词 “想” -
    {"vm_xiang", "Vxiang", Pos::Vmodals | Pos::Contws},
  }

  VMODPOS = Pos::Vmodals | Pos::Contws
  Vmodal  = new(Tag::Vmodal, VMODPOS)
  VmHui   = new(Tag::Vmodal, VMODPOS)
  VmNeng  = new(Tag::Vmodal, VMODPOS)
  VmXiang = new(Tag::Vmodal, VMODPOS)

  @[AlwaysInline]
  def vmodals?
    @pos.vmodals?
  end

  def self.map_vmodals(key : ::String)
    case key
    when "会" then VmHui # động từ `hội`
    when "能" then VmHui # động từ `năng`
    when "想" then VmHui # động từ `tưởng`
    else          Vmodal
    end
  end
end
