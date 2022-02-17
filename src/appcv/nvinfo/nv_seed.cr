module CV::NvSeed
  extend self

  MAP_ID = {
    "chivi" => 0,
    "staff" => 1,
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

  def map_type(sname : String)
    case sname
    when "chivi"
      0 # act as mirror
    when "users", "staff", "zxcs_me"
      1 # manual update
    when "jx_la", "nofff", "zhwenpg", "shubaow"
      2 # dead remote
    when "paoshu8", "duokan8", "5200", "hetushu"
      4 # slow but still alive
    else
      3 # alive and fast enough
    end
  end

  MAP_ID.each_key do |sname|
    FileUtils.mkdir_p("var/chtexts/#{sname}/_")
  end

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

  def remote?(sname : String, privi = 4)
    case sname
    when "5200", "bqg_5200", "rengshu"
      privi >= 0 || yield
    when "bxwxorg", "xbiquge", "biqubao", "69shu"
      privi >= 1 || yield
    when "hetushu", "paoshu8", "duokan8", "nofff"
      privi >= 2 || yield
    when "shubaow", "zhwenpg"
      privi > 4
    else false
    end
  end

  def remote?(sname : String, privi : Int32 = 4, special_case = false)
    remote?(sname, privi) { special_case }
  end

  REMOTES = {
    "69shu", "5200", "bxwxorg",
    "bqg_5200", "nofff", "biqubao",
    "rengshu", "hetushu", "xbiquge",
    "duokan8", "paoshu8",
  }
end
