module CV::Zhseed
  extend self

  SNAMES = {
    "chivi", "zxcs_me", "zadzs", "thuyvicu", "hotupub",
    "hetushu", "bxwxorg", "69shu", "xbiquge", "rengshu",
    "biqubao", "bqg_5200", "5200", "nofff", "paoshu8",
    "zhwenpg", "duokan8", "shubaow", "jx_la",
  }

  def zseed(index : Int32)
    SNAMES[index]? || "chivi"
  end

  def index(zseed : String)
    SNAMES.index(zseed) || 0
  end

  def remote?(zseed : String, privi : Int32 = 4)
    case zseed
    when "chivi", "zxcs_me", "zadzs", "thuyvicu", "hotupub"
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
