enum MT::DictKind : Int16
  System = 0 # system dict
  Global = 1 # regular dict

  Themes = 4 # common themes
  Wnovel = 5 # use for chivi official book series
  Userpj = 6 # use for user created series
  Public = 7 # use for public domain series
  Userqt = 8 # unique for each user, use for every quick trans posts

  def vname
    case self
    when System then "hệ thống"
    when Global then "thông dụng"
    when Themes then "văn cảnh riêng"
    when Wnovel then "bộ truyện chữ"
    when Userpj then "sưu tầm cá nhân"
    when Public then "sở hữu công cộng"
    when Userqt then "dịch nhanh cá nhân"
    end
  end

  def self.p_min(dname : String)
    case dname
    when /^(book|wn|up|qt|tm|pd)/  then 0
    when /regular|combine|suggest/ then 1
    when .ends_with?("pair")       then 1
    else                                2
    end
  end
end
