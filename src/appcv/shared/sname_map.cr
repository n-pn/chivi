module CV::SnameMap
  extend self

  ORDERS = {
    "zxcs_me",
    "hetushu",

    "bxwxorg",
    "69shu",

    "xbiquge",
    "rengshu",

    "b5200",
    "biqugse",
    "bqxs520",

    "biqugee",
    "paoshu8",
    "duokan8",
    "shubaow",
    "kanshu8",

    "ptwxz",
    "uuks",
    "yannuozw",

    "uukanshu",
    "133txt",

    "biqu5200",
    "5200",

    "sdyfcm",
    "jx_la",
    "zhwenpg",
  }

  def map_type(sname : String)
    case sname
    when "=base", "=user", "users"
      0 # act as mirror
    when "zxcs_me", .starts_with?('@')
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
