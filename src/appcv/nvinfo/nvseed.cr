module CV::Nvseed
  extend self

  MAP_ID = {
    "chivi" => -1,
    "local" => 0,

    "zxcs_me" => 2,
    "hetushu" => 4,

    "bxwxorg" => 8,
    "69shu"   => 10,

    "xbiquge" => 20,
    "rengshu" => 22,
    "biqubao" => 24,
    "paoshu8" => 26,
    "shubaow" => 28,

    "bqg_5200" => 40,
    "5200"     => 42,
    "nofff"    => 44,
    "zhwenpg"  => 46,
    "duokan8"  => 48,

    "jx_la" => 80,
  }

  def map_id(sname : String)
    MAP_ID[sname]? || 990
  end

  MAP_NAME = MAP_ID.invert

  def map_name(index : Int32)
    MAP_NAME[index] || "chivi"
  end

  def to_s(ids : Array(Int32))
    ids.map { |id| map_name(id) }
  end

  REMOTES = {
    "69shu", "5200", "bxwxorg", "bqg_5200", "nofff", "biqubao",
    "rengshu", "hetushu", "xbiquge", "duokan8", "paoshu8",
  }

  def remote?(sname : String, privi : Int32 = 4, special_case = false)
    case sname
    when "5200", "bqg_5200", "rengshu", "nofff"
      privi >= 0 || special_case
    when "hetushu", "bxwxorg", "xbiquge", "biqubao"
      privi >= 1 || special_case
    when "69shu", "paoshu8", "duokan8"
      privi >= 2 || special_case
    when "shubaow" # only works in real pc environment
      privi >= 3 && ENV["AMBER_ENV"]? != "production"
    else false
    end
  end
end
