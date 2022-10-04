struct CV::PosTag
  PREPOS_MAP = {
    "把"  => new(:pre_ba3),
    "对"  => new(:pre_dui),
    "被"  => new(:pre_bei),
    "在"  => new(:pre_zai),
    "比"  => new(:pre_bi3),
    "不比" => new(:pre_bubi),
    "将"  => new(:pre_jiang),
    "和"  => new(:pre_he2),
    "与"  => new(:pre_yu3),
    "同"  => new(:pre_tong),
    "跟"  => new(:pre_gen1),
    "让"  => new(:pre_rang),
    "令"  => new(:pre_ling),
    "给"  => new(:pre_gei3),
    "自"  => new(:pre_zi4),
  }

  def self.map_prepos(key : String)
    PREPOS_MAP[key] || new(:prepos)
  end

  PARTICLE_MAP = {
    "了"  => new(:pt_le, :aspect),
    "喽"  => new(:pt_le, :aspect),
    "着"  => new(:pt_zhe, :aspect),
    "过"  => new(:pt_guo, :aspect),
    "所"  => new(:pt_suo, :vauxil),
    "来说" => new(:pt_laishuo),
    "说来" => new(:pt_shuolai),
    "来讲" => new(:pt_laijiang),
    "而言" => new(:pt_eryan),
    "的话" => new(:pt_dehua),
    "之"  => new(:pt_zhi),
    "的"  => new(:pt_dep),
    "得"  => new(:pt_der),
    "地"  => new(:pt_dev),
    "云云" => new(:pt_yunyun),
    "等"  => new(:pt_deng1),
    "等等" => new(:pt_deng2),
    "等人" => new(:pt_deng3),
    "一样" => new(:pt_yiyang),
    "一般" => new(:pt_yiban),
    "似的" => new(:pt_shide),
    "般"  => new(:pt_ban),
  }

  def self.map_particle(key : String)
    PARTICLE_MAP[key] ||= new(:pt_cl)
  end
end
