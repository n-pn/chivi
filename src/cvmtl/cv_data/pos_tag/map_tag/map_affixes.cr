module MT::PosTag
  PREFIX_MAP = {
    "可" => make(:pref_ke3),
    "第" => make(:pref_di4),
  }

  SUFFIX_MAP = load_map("map_suff")

  def self.map_affix(tag : String, key : String)
    if tag[1]? == 'k'
      return make(:suf_zhi) if key[0] == '之'
      return SUFFIX_MAP[key]? || make(:suf_noun)
    end

    case tag
    when "Gia" then make(:inf_adjt)
    when "Giv" then make(:inf_verb)
    when "Ghm" then make(:pref_num)
    when "Ghs" then PREFIX_MAP[key]? || make(:lit_blank)
    else            make(:lit_blank)
    end
  end
end
