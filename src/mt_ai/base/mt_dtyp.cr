enum MT::MtDtyp : Int16
  System = 0 # system dict
  Global = 1 # regular dict

  Domain = 4 # common themes
  Wnovel = 5 # use for chivi official book series
  Userpj = 6 # use for user created series
  Public = 7 # use for public domain series
  Userqt = 8 # unique for each user, use for every quick trans posts

  def vname
    case self
    when System then "hệ thống"
    when Global then "thông dụng"
    when Domain then "văn cảnh riêng"
    when Wnovel then "bộ truyện chữ"
    when Userpj then "sưu tầm cá nhân"
    when Public then "sở hữu công cộng"
    when Userqt then "dịch nhanh cá nhân"
    end
  end

  def self.p_min(dname : String)
    case dname
    when .starts_with?(/wn|dm|up|qt|pd/) then 0
    when /regular|combine|suggest/       then 1
    when .ends_with?("pair")             then 1
    else                                      2
    end
  end

  @@cache_id = {
    "essence" => 10,
    "word_hv" => 20,
    "pin_yin" => 30,

    "noun_vi" => 110,
    "verb_vi" => 120,
    "adjt_vi" => 130,

    "time_vi" => 150,
    "nqnt_vi" => 160,

    "name_hv" => 210,
    "name_ja" => 220,
    "name_en" => 230,

    "b_title" => 310,
    "c_title" => 320,

    "regular" => 11,
    "combine" => 21,
    "suggest" => 31,

    "m_n_pair" => 211,
    "m_v_pair" => 221,
    "v_n_pair" => 231,
    "v_v_pair" => 241,
    "v_c_pair" => 251,
    "p_v_pair" => 261,
    "d_v_pair" => 271,
  }

  def self.map_id(dname : String)
    @@cache_id[dname] ||=
      case dname
      when .starts_with?("wn") then 10 * dname[2..].to_i + Wnovel.value
      when .starts_with?("up") then 10 * dname[2..].to_i + Userpj.value
      when .starts_with?("qt") then 10 * dname[2..].to_i + Userqt.value
      when .starts_with?("dm") then 10 * dname[2..].to_i + Domain.value
      when .starts_with?("pd") then 10 * dname[2..].to_i + Public.value
      else                          raise "invalid dname #{dname}"
      end
  end

  @[AlwaysInline]
  def self.qtd_id(vu_id : Int32)
    vu_id &* 10 &+ Userqt.value
  end
end
