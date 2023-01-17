module CV::SnameMap
  extend self

  ORDERS = {
    "zxcs_me",
    "hetushu",

    "69shu",
    "uukanshu",

    "xbiquge",
    "rengshu",

    "b5200",
    "biqugse",
    "bqxs520",

    "bxwxorg",
    "biqugee",
    "paoshu8",
    "duokan8",
    "shubaow",
    "kanshu8",

    "uuks",
    "ptwxz",
    "bxwxio",
    "133txt",
    "yannuozw",
    "biqu5200",

    "5200",
    "sdyfcm",
    "jx_la",
  }

  MAP_SN_ID = {
    "=base", "=user", "miscs",
    "zxcs_me", "hetushu", "jx_la",
    "bxwxorg", "xbiquge", "69shu",
    "rengshu", "biqugee", "shubaow",
    "sdyfcm", "paoshu8", "duokan8",
    "uukanshu", "ptwxz", "biqugse",
    "yannuozw", "uuks", "bqxs520",
    "biqu5200", "133txt", "b5200",
    "kanshu8", "5200", "bxwxio",
  }

  def sn_id(sname : String) : Int32
    MAP_SN_ID.index(sname).try { |x| x &* 2 &+ 1 } || raise "Invalid seed name"
  end

  def map_type(sname : String)
    case sname
    when "=base", "=user", "users"
      0 # act as mirror
    when "zxcs_me", "miscs", .starts_with?('@')
      1 # manual update
    when "jx_la", "shubaow", "sdyfcm", "biqugee",
         "bxwxorg", "5200", "duokan8"
      2 # dead remote
    when "paoshu8", "hetushu", "ptwxz", "kanshu8"
      3  # slow but still alive
    else # "69shu", "xbiquge", "rengshu"
      4  # fast remote
    end
  end

  def remote?(sname : String) : Bool
    map_type(sname) > 2
  end

  def alive_snames : Array(String)
    ORDERS.select { |sname| map_type(sname) > 2 }
  end

  def zseed(sname : String)
    ORDERS.index(sname) || 100
  end
end
