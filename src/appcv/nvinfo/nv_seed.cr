module CV::NvSeed
  extend self

  MAP_ID = {
    "chivi" => 0,
    "local" => 1,
    "users" => 63,

    "zxcs_me" => 2,
    "hetushu" => 4,

    "bxwxorg" => 8,
    "69shu"   => 10,

    "xbiquge" => 16,
    "rengshu" => 18,
    "biqubao" => 20,
    "paoshu8" => 22,
    "shubaow" => 24,

    "bqg_5200" => 32,
    "5200"     => 34,
    "nofff"    => 36,
    "zhwenpg"  => 38,
    "duokan8"  => 40,

    "jx_la" => 60,
  }

  def map_id(sname : Array(String))
    sname.map { |x| map_id(x) }.uniq
  end

  def map_id(sname : String)
    MAP_ID[sname]? || 63
  end

  MAP_NAME = MAP_ID.invert

  def map_name(index : Int32)
    MAP_NAME[index] || "users"
  end

  def to_s(ids : Array(Int32))
    ids.map { |id| map_name(id) }
  end

  REMOTES = {
    "69shu", "5200", "bxwxorg",
    "bqg_5200", "nofff", "biqubao",
    "rengshu", "hetushu", "xbiquge",
    "duokan8", "paoshu8",
  }

  def remote?(sname : String, privi : Int32 = 4, special_case = false)
    remote?(sname, privi) { special_case }
  end

  def remote?(sname : String, privi = 4)
    case sname
    when "5200", "bqg_5200", "rengshu", "nofff"
      privi >= 0 || yield
    when "hetushu", "bxwxorg", "xbiquge", "biqubao"
      privi >= 1 || yield
    when "69shu", "paoshu8", "duokan8"
      privi >= 2 || yield
    when "shubaow", "zhwenpg"
      privi > 4
    else false
    end
  end
end
