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
    "133txt",
    "yannuozw",
    "biqu5200",

    "5200",
    "sdyfcm",
    "jx_la",
    "zhwenpg",
  }

  MAP_SN_ID = {
    "=base", "=user", "miscs",
    "zxcs_me", "hetushu", "jx_la",
    "bxwxorg", "xbiquge", "69shu",
    "rengshu", "biqugee", "shubaow",
    "sdyfcm", "paoshu8", "duokan8",
  }

  def sn_id(sname : String) : Int32
    MAP_SN_ID.index(sname).try { |x| x &* 2 &+ 1 } || raise "Invalid seed name"
  end

  def map_type(sname : String)
    case sname
    when "=base", "=user"
      0 # act as mirror
    when "zxcs_me", .starts_with?('@'), "users"
      1 # manual update
    when "jx_la", "zhwenpg", "shubaow", "sdyfcm", "biqugee",
         "bxwxorg"
      2 # dead remote
    when "paoshu8", "hetushu", "5200", "biqu5200", "ptwxz",
         "duokan8", "uukanshu"
      3  # slow but still alive
    else # "bxwxorg", "69shu", "xbiquge", "rengshu", "biqugee"
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
