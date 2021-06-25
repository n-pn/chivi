module CV::Zhseed
  extend self

  # rsvd_x => reversed places

  SNAMES = {
    "chivi", "zxcs_me", "hetushu", "bxwxorg", "69shu",
    "rsvd_0", "rsvd_1", "rsvd_2", "rsvd_3", "rsvd_4",

    "xbiquge", "rengshu", "biqubao", "paoshu8", "shubaow",
    "rsvd_5", "rsvd_6", "rsvd_7", "rsvd_8", "rsvd_9",

    "bqg_5200", "5200", "nofff", "zhwenpg", "duokan8",
    "rsvd_10", "rsvd_11", "rsvd_12", "rsvd_13", "rsvd_14",

    "jx_la",
  }

  def all(ids : Array(Int32))
    ids.map { |id| zseed(id) }
  end

  def zseed(index : Int32)
    SNAMES[index]? || "chivi"
  end

  def index(zseed : String)
    SNAMES.index(zseed) || 0
  end

  def remote?(zseed : String, privi : Int32 = 4)
    case zseed
    when "chivi", "zxcs_me"
      false
    when "5200", "bqg_5200", "rengshu", "nofff"
      true
    when "hetushu", "biqubao", "bxwxorg", "xbiquge"
      privi > 0
    when "zhwenpg", "69shu", "paoshu8", "duokan8"
      privi > 1
    else
      privi > 3
    end
  end
end
