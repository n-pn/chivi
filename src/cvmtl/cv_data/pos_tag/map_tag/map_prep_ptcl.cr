module MT::PosTag
  PREPOS_MAP = {
    "把"  => make(:pre_ba3),
    "对"  => make(:pre_dui),
    "被"  => make(:pre_bei),
    "在"  => make(:pre_zai),
    "比"  => make(:pre_bi3),
    "不比" => make(:pre_bubi),
    "将"  => make(:pre_jiang),
    "和"  => make(:pre_he2),
    "与"  => make(:pre_yu3),
    "同"  => make(:pre_tong),
    "跟"  => make(:pre_gen1),
    "让"  => make(:pre_rang),
    "令"  => make(:pre_ling),
    "给"  => make(:pre_gei3),
    "自"  => make(:pre_zi4),
    "从"  => make(:pre_cong, :at_tail),
  }

  def self.map_prepos(key : String)
    PREPOS_MAP[key]? || make(:prepos)
  end

  PARTICLE_MAP = {
    "了"  => make(:pt_le, :aspect),
    "喽"  => make(:pt_le, :aspect),
    "着"  => make(:pt_zhe, :aspect),
    "过"  => make(:pt_guo, :aspect),
    "所"  => make(:pt_suo, :vauxil),
    "来说" => make(:pt_laishuo),
    "说来" => make(:pt_shuolai),
    "来讲" => make(:pt_laijiang),
    "而言" => make(:pt_eryan),
    "的话" => make(:pt_dehua),
    "连"  => make(:pt_lian2),
    "之"  => make(:pt_zhi),
    "的"  => make(:pt_dep),
    "得"  => make(:pt_der),
    "地"  => make(:pt_dev),
    "云云" => make(:pt_yunyun),
    "等"  => make(:pt_deng1),
    "等等" => make(:pt_deng2),
    "等人" => make(:pt_deng3),
    "一样" => make(:pt_yiyang),
    "一般" => make(:pt_yiban),
    "似的" => make(:pt_shide),
    "般"  => make(:pt_ban),
  }

  def self.map_particle(key : String)
    PARTICLE_MAP[key]? || make(:pt_cl)
  end
end
