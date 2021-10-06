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
    ids.map { |id| sname(id) }
  end

  def sname(index : Int32)
    SNAMES[index]? || "chivi"
  end

  def index(sname : String)
    SNAMES.index(sname) || 0
  end

  def remote?(sname : String, privi : Int32 = 4, special_case = false)
    case sname
    when "5200", "bqg_5200", "rengshu", "nofff"
      privi >= 0 || special_case
    when "hetushu", "bxwxorg", "xbiquge", "buqubao"
      privi >= 1 || special_case
    when "69shu", "paoshu8", "duokan8"
      privi >= 2 || special_case
    when "shubaow" # only works in real pc environment
      privi >= 3 && ENV["AMBER_ENV"]? != "production"
    else false
    end
  end
end
